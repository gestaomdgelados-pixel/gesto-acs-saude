-- Gestão ACS Saúde — área do morador (4º script, depois do comunicacao.sql).
-- Pode rodar mais de uma vez sem erro.

-- ===== Família ligada ao login do morador =====
alter table public.acs_familias add column if not exists usuario_id uuid
  references public.profiles(id) on delete set null;
create index if not exists acs_familias_usuario_idx on public.acs_familias (usuario_id);

-- O morador só LÊ os dados da própria família.
drop policy if exists acs_familias_morador on public.acs_familias;
create policy acs_familias_morador on public.acs_familias for select to authenticated
  using (usuario_id = auth.uid());

drop policy if exists acs_membros_morador on public.acs_membros;
create policy acs_membros_morador on public.acs_membros for select to authenticated
  using (familia_id in (select f.id from public.acs_familias f where f.usuario_id = auth.uid()));

drop policy if exists acs_vacinas_tipos_morador on public.acs_vacinas_tipos;
create policy acs_vacinas_tipos_morador on public.acs_vacinas_tipos for select to authenticated
  using (agente_id in (select f.agente_id from public.acs_familias f where f.usuario_id = auth.uid()));

drop policy if exists acs_vacinas_morador on public.acs_vacinas;
create policy acs_vacinas_morador on public.acs_vacinas for select to authenticated
  using (membro_id in (
    select m.id from public.acs_membros m
    join public.acs_familias f on f.id = m.familia_id
    where f.usuario_id = auth.uid()));

drop policy if exists acs_visitas_morador on public.acs_visitas;
create policy acs_visitas_morador on public.acs_visitas for select to authenticated
  using (familia_id in (select f.id from public.acs_familias f where f.usuario_id = auth.uid()));

-- ===== Cancelamento de visita pelo morador (justificativa obrigatória) =====
alter table public.acs_visitas add column if not exists cancelada_pelo_morador boolean not null default false;
alter table public.acs_visitas add column if not exists cancelada_em timestamptz;

create or replace function public.acs_cancelar_visita(p_id uuid, p_motivo text)
returns void language plpgsql security definer set search_path = public as $$
begin
  if coalesce(trim(p_motivo), '') = '' then
    raise exception 'Informe a justificativa do cancelamento.';
  end if;
  update public.acs_visitas
     set status = 'nao_realizada',
         justificativa = 'Cancelada pelo morador: ' || trim(p_motivo),
         cancelada_pelo_morador = true,
         cancelada_em = now()
   where id = p_id and status = 'agendada'
     and familia_id in (select f.id from public.acs_familias f where f.usuario_id = auth.uid());
  if not found then
    raise exception 'Não foi possível cancelar: a visita não está mais agendada.';
  end if;
end $$;
revoke all on function public.acs_cancelar_visita(uuid, text) from public, anon;
grant execute on function public.acs_cancelar_visita(uuid, text) to authenticated;

-- ===== Agente liga a família ao login do morador =====
create or replace function public.acs_vincular_morador(p_familia uuid, p_usuario text)
returns text language plpgsql security definer set search_path = public as $$
declare v_id uuid; v_nome text;
begin
  if public.meu_papel() is distinct from 'agente' then
    raise exception 'Só o agente pode vincular famílias.';
  end if;
  select p.id, p.nome into v_id, v_nome from public.profiles p
   where p.ativo and p.role = 'usuario'
     and lower(p.usuario) = lower(trim(both '@' from trim(p_usuario)))
   limit 1;
  if v_id is null then
    raise exception 'Nenhum login de usuário comum com esse nome de usuário.';
  end if;
  update public.acs_familias set usuario_id = v_id
   where id = p_familia and agente_id = auth.uid();
  if not found then
    raise exception 'Família não encontrada.';
  end if;
  return v_nome;
end $$;
revoke all on function public.acs_vincular_morador(uuid, text) from public, anon;
grant execute on function public.acs_vincular_morador(uuid, text) to authenticated;

-- ===== Contato do agente =====
create table if not exists public.acs_agente_contato (
  agente_id uuid primary key default auth.uid() references public.profiles(id) on delete cascade,
  area text,
  telefone text,
  whatsapp text,
  dias text,
  horarios text,
  updated_at timestamptz not null default now()
);
alter table public.acs_agente_contato enable row level security;

drop policy if exists acs_agente_contato_dono on public.acs_agente_contato;
create policy acs_agente_contato_dono on public.acs_agente_contato for all to authenticated
  using (agente_id = auth.uid() and public.meu_papel() = 'agente')
  with check (agente_id = auth.uid() and public.meu_papel() = 'agente');

-- O morador vê o contato da agente definida pelo admin.
create or replace function public.acs_contato_do_agente()
returns table (nome text, area text, telefone text, whatsapp text, dias text, horarios text)
language sql stable security definer set search_path = public as $$
  select a.nome, c.area, c.telefone, c.whatsapp, c.dias, c.horarios
  from public.profiles eu
  join public.profiles a on a.id = eu.agente_id and a.ativo
  left join public.acs_agente_contato c on c.agente_id = a.id
  where eu.id = auth.uid()
  limit 1
$$;
revoke all on function public.acs_contato_do_agente() from public, anon;
grant execute on function public.acs_contato_do_agente() to authenticated;
