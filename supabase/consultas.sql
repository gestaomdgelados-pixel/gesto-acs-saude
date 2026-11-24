-- Gestão ACS Saúde — consultas (2º script, depois do agentes.sql).
-- Pode rodar mais de uma vez sem erro.

create table if not exists public.acs_consultas (
  id uuid primary key default gen_random_uuid(),
  solicitante_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  agente_id uuid not null references public.profiles(id) on delete cascade,
  paciente text not null,
  especialidade text not null,
  created_at timestamptz not null default now()
);
alter table public.acs_consultas add column if not exists membro_id uuid
  references public.acs_membros(id) on delete set null;
alter table public.acs_consultas add column if not exists observacao text;
alter table public.acs_consultas add column if not exists status text not null default 'solicitada'
  check (status in ('solicitada', 'aceita', 'cancelada'));
alter table public.acs_consultas add column if not exists data_marcada timestamptz;
alter table public.acs_consultas add column if not exists motivo text;

alter table public.acs_consultas enable row level security;

-- Lista de agentes (só id e nome) para o usuário escolher a responsável.
create or replace function public.acs_agentes()
returns table (id uuid, nome text) language sql stable security definer set search_path = public as $$
  select p.id, p.nome from public.profiles p
  where p.role = 'agente' and p.ativo and auth.uid() is not null
  order by p.nome
$$;
revoke all on function public.acs_agentes() from public, anon;
grant execute on function public.acs_agentes() to authenticated;

drop policy if exists acs_consultas_select on public.acs_consultas;
create policy acs_consultas_select on public.acs_consultas for select to authenticated
  using (solicitante_id = auth.uid() or agente_id = auth.uid() or public.meu_papel() in ('gestao', 'admin'));

-- Usuário: só pede para a agente em cujo sistema ele está cadastrado.
-- Agente: só pede para pessoas que ele mesmo cadastrou.
drop policy if exists acs_consultas_insert on public.acs_consultas;
create policy acs_consultas_insert on public.acs_consultas for insert to authenticated
  with check (
    solicitante_id = auth.uid() and status = 'solicitada' and (
      (public.meu_papel() = 'usuario' and membro_id is null and exists (
        select 1 from public.profiles p where p.id = auth.uid() and p.agente_id = acs_consultas.agente_id))
      or (public.meu_papel() = 'agente' and agente_id = auth.uid() and exists (
        select 1 from public.acs_membros m where m.id = acs_consultas.membro_id and m.agente_id = auth.uid()))
    )
  );

-- Gestão e admin aceitam ou cancelam.
drop policy if exists acs_consultas_gestao on public.acs_consultas;
create policy acs_consultas_gestao on public.acs_consultas for update to authenticated
  using (public.meu_papel() in ('gestao', 'admin'))
  with check (public.meu_papel() in ('gestao', 'admin'));

-- Quem pediu pode cancelar enquanto ainda está solicitada.
drop policy if exists acs_consultas_cancelar on public.acs_consultas;
create policy acs_consultas_cancelar on public.acs_consultas for update to authenticated
  using (solicitante_id = auth.uid() and status = 'solicitada')
  with check (solicitante_id = auth.uid() and status = 'cancelada');
