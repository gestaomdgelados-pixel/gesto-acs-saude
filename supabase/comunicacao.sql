-- Gestão ACS Saúde — comunicação entre logins, versões, contato do admin e status vistos.
-- 3º script: rode depois do agentes.sql e do consultas.sql. Pode rodar mais de uma vez sem erro.

-- ===== Funções auxiliares =====
create or replace function public.acs_eh_gestao(p_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = p_id and role = 'gestao' and ativo)
$$;
revoke all on function public.acs_eh_gestao(uuid) from public, anon;
grant execute on function public.acs_eh_gestao(uuid) to authenticated;

-- Procura um login pelo nome de usuário exato (só devolve se existir, estiver ativo e tiver o perfil pedido).
create or replace function public.acs_buscar_login(p_usuario text, p_role text)
returns table (id uuid, nome text) language sql stable security definer set search_path = public as $$
  select p.id, p.nome from public.profiles p
  where auth.uid() is not null and p.ativo and p.role = p_role
    and lower(p.usuario) = lower(trim(both '@' from trim(p_usuario)))
  limit 1
$$;
revoke all on function public.acs_buscar_login(text, text) from public, anon;
grant execute on function public.acs_buscar_login(text, text) to authenticated;

-- ===== Consultas: encaminhamento para UMA pessoa da gestão =====
alter table public.acs_consultas add column if not exists gestor_id uuid
  references public.profiles(id) on delete set null; -- excluiu a pessoa da gestão? volta para a agente
alter table public.acs_consultas add column if not exists gestor_usuario text;
alter table public.acs_consultas add column if not exists encaminhada_em timestamptz;
alter table public.acs_consultas add column if not exists agente_recebido_em timestamptz;
alter table public.acs_consultas add column if not exists agente_visto_em timestamptz;
alter table public.acs_consultas add column if not exists gestor_recebido_em timestamptz;
alter table public.acs_consultas add column if not exists gestor_visto_em timestamptz;

-- Cada pessoa da gestão vê só as consultas encaminhadas para ela.
drop policy if exists acs_consultas_select on public.acs_consultas;
create policy acs_consultas_select on public.acs_consultas for select to authenticated
  using (solicitante_id = auth.uid() or agente_id = auth.uid() or gestor_id = auth.uid()
         or public.meu_papel() = 'admin');

drop policy if exists acs_consultas_gestao on public.acs_consultas;
create policy acs_consultas_gestao on public.acs_consultas for update to authenticated
  using (public.meu_papel() = 'admin' or (public.meu_papel() = 'gestao' and gestor_id = auth.uid()))
  with check (public.meu_papel() = 'admin' or (public.meu_papel() = 'gestao' and gestor_id = auth.uid()));

-- A agente encaminha/reencaminha e marca como recebida/vista (nunca aceita).
drop policy if exists acs_consultas_agente on public.acs_consultas;
create policy acs_consultas_agente on public.acs_consultas for update to authenticated
  using (public.meu_papel() = 'agente' and agente_id = auth.uid())
  with check (public.meu_papel() = 'agente' and agente_id = auth.uid() and status <> 'aceita'
              and (gestor_id is null or public.acs_eh_gestao(gestor_id)));

-- ===== Documentos (PDF) da agente para UMA pessoa da gestão =====
create table if not exists public.acs_documentos (
  id uuid primary key default gen_random_uuid(),
  remetente_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  destinatario_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.acs_documentos add column if not exists remetente_nome text;
alter table public.acs_documentos add column if not exists destinatario_usuario text;
alter table public.acs_documentos add column if not exists nome_arquivo text;
alter table public.acs_documentos add column if not exists caminho text;
alter table public.acs_documentos add column if not exists recebido_em timestamptz;
alter table public.acs_documentos add column if not exists visto_em timestamptz;
alter table public.acs_documentos enable row level security;

drop policy if exists acs_documentos_select on public.acs_documentos;
create policy acs_documentos_select on public.acs_documentos for select to authenticated
  using (remetente_id = auth.uid() or destinatario_id = auth.uid() or public.meu_papel() = 'admin');
drop policy if exists acs_documentos_insert on public.acs_documentos;
create policy acs_documentos_insert on public.acs_documentos for insert to authenticated
  with check (remetente_id = auth.uid() and public.meu_papel() = 'agente'
              and public.acs_eh_gestao(destinatario_id));
drop policy if exists acs_documentos_update on public.acs_documentos;
create policy acs_documentos_update on public.acs_documentos for update to authenticated
  using (destinatario_id = auth.uid()) with check (destinatario_id = auth.uid());

-- Pasta PRIVADA dos PDFs (até 20 MB): só quem enviou e quem recebeu abrem.
insert into storage.buckets (id, name, public, file_size_limit)
values ('documentos', 'documentos', false, 20971520)
on conflict (id) do update set public = false, file_size_limit = 20971520;

drop policy if exists acs_documentos_up on storage.objects;
create policy acs_documentos_up on storage.objects for insert to authenticated
  with check (bucket_id = 'documentos' and public.meu_papel() = 'agente'
              and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists acs_documentos_ler on storage.objects;
create policy acs_documentos_ler on storage.objects for select to authenticated
  using (bucket_id = 'documentos' and (
    (storage.foldername(name))[1] = auth.uid()::text
    or exists (select 1 from public.acs_documentos d where d.caminho = name and d.destinatario_id = auth.uid())
    or public.meu_papel() = 'admin'));
drop policy if exists acs_documentos_apagar on storage.objects;
create policy acs_documentos_apagar on storage.objects for delete to authenticated
  using (bucket_id = 'documentos' and (storage.foldername(name))[1] = auth.uid()::text);

-- ===== Configurações gerais (número do administrador) =====
create table if not exists public.acs_config (
  chave text primary key,
  valor text,
  updated_at timestamptz not null default now()
);
alter table public.acs_config enable row level security;
drop policy if exists acs_config_select on public.acs_config;
create policy acs_config_select on public.acs_config for select to authenticated using (true);
drop policy if exists acs_config_admin on public.acs_config;
create policy acs_config_admin on public.acs_config for all to authenticated
  using (public.meu_papel() = 'admin') with check (public.meu_papel() = 'admin');

-- ===== Versões do app =====
create table if not exists public.acs_versoes (
  id uuid primary key default gen_random_uuid(),
  versao text not null,
  created_at timestamptz not null default now()
);
alter table public.acs_versoes add column if not exists notas text;
alter table public.acs_versoes add column if not exists arquivo_url text;
alter table public.acs_versoes add column if not exists criado_por uuid
  references public.profiles(id) on delete set null;
alter table public.acs_versoes enable row level security;
drop policy if exists acs_versoes_select on public.acs_versoes;
create policy acs_versoes_select on public.acs_versoes for select to authenticated using (true);
drop policy if exists acs_versoes_escrita on public.acs_versoes;
create policy acs_versoes_escrita on public.acs_versoes for all to authenticated
  using (public.meu_papel() in ('gestao', 'admin')) with check (public.meu_papel() in ('gestao', 'admin'));

insert into storage.buckets (id, name, public, file_size_limit)
values ('versoes', 'versoes', true, 52428800)
on conflict (id) do update set public = true, file_size_limit = 52428800;
drop policy if exists acs_versoes_up on storage.objects;
create policy acs_versoes_up on storage.objects for insert to authenticated
  with check (bucket_id = 'versoes' and public.meu_papel() in ('gestao', 'admin'));
drop policy if exists acs_versoes_apagar on storage.objects;
create policy acs_versoes_apagar on storage.objects for delete to authenticated
  using (bucket_id = 'versoes' and public.meu_papel() in ('gestao', 'admin'));

-- ===== Status (stories): a gestão também publica imagem/vídeo =====
drop policy if exists acs_propagandas_insert on storage.objects;
create policy acs_propagandas_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'propagandas' and public.meu_papel() in ('admin', 'gestao'));
drop policy if exists acs_propagandas_delete on storage.objects;
create policy acs_propagandas_delete on storage.objects for delete to authenticated
  using (bucket_id = 'propagandas' and public.meu_papel() in ('admin', 'gestao'));

-- Status já vistos por cada login.
create table if not exists public.acs_stories_vistos (
  story_id text not null,
  usuario_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  visto_em timestamptz not null default now(),
  primary key (story_id, usuario_id)
);
alter table public.acs_stories_vistos enable row level security;
drop policy if exists acs_vistos_select on public.acs_stories_vistos;
create policy acs_vistos_select on public.acs_stories_vistos for select to authenticated
  using (usuario_id = auth.uid());
drop policy if exists acs_vistos_insert on public.acs_stories_vistos;
create policy acs_vistos_insert on public.acs_stories_vistos for insert to authenticated
  with check (usuario_id = auth.uid());
