-- ACS Saúde — configuração única. Cole no SQL Editor do Supabase e rode.
-- PASSO 0 (antes): Authentication → Users → Add user → Create new user
--   e-mail: gestaomd@seuapp.com  senha: 251540@  (marque "Auto Confirm User")

-- 1) Colunas novas usadas pelo app
alter table public.stories  add column if not exists midia_url  text;
alter table public.stories  add column if not exists midia_tipo text;
alter table public.reunioes add column if not exists tipo text not null default 'reuniao';

-- 2) Função auxiliar: papel de quem está logado (evita recursão nas regras)
create or replace function public.meu_papel()
returns text language sql stable security definer set search_path = public as $$
  select role from public.profiles where id = auth.uid() and ativo
$$;

-- 3) Regras de acesso (RLS) usadas pelo app
alter table public.profiles     enable row level security;
alter table public.stories      enable row level security;
alter table public.reunioes     enable row level security;
alter table public.solicitacoes enable row level security;
alter table public.logs         enable row level security;

drop policy if exists acs_profiles_select on public.profiles;
create policy acs_profiles_select on public.profiles for select to authenticated
  using (id = auth.uid() or public.meu_papel() in ('admin','gestao') or agente_id = auth.uid());
-- Nenhuma regra de insert/update em profiles: só a Edge Function (admin) altera perfis.

drop policy if exists acs_stories_select on public.stories;
create policy acs_stories_select on public.stories for select to authenticated using (true);
drop policy if exists acs_stories_write on public.stories;
create policy acs_stories_write on public.stories for all to authenticated
  using (public.meu_papel() in ('admin','gestao'))
  with check (public.meu_papel() in ('admin','gestao'));

drop policy if exists acs_reunioes_select on public.reunioes;
create policy acs_reunioes_select on public.reunioes for select to authenticated
  using (public.meu_papel() in ('agente','gestao','admin'));
drop policy if exists acs_reunioes_write on public.reunioes;
create policy acs_reunioes_write on public.reunioes for all to authenticated
  using (public.meu_papel() in ('gestao','admin'))
  with check (public.meu_papel() in ('gestao','admin'));

drop policy if exists acs_solic_select on public.solicitacoes;
create policy acs_solic_select on public.solicitacoes for select to authenticated
  using (usuario_id = auth.uid() or agente_id = auth.uid() or public.meu_papel() in ('gestao','admin'));
drop policy if exists acs_solic_insert on public.solicitacoes;
create policy acs_solic_insert on public.solicitacoes for insert to authenticated
  with check (usuario_id = auth.uid() and public.meu_papel() is not null);
drop policy if exists acs_solic_update on public.solicitacoes;
create policy acs_solic_update on public.solicitacoes for update to authenticated
  using (public.meu_papel() in ('gestao','admin'))
  with check (public.meu_papel() in ('gestao','admin'));

drop policy if exists acs_logs_select on public.logs;
create policy acs_logs_select on public.logs for select to authenticated
  using (public.meu_papel() = 'admin');

-- 4) Pasta pública de propagandas (até 50 MB por arquivo) — só admin envia
insert into storage.buckets (id, name, public, file_size_limit)
values ('propagandas', 'propagandas', true, 52428800)
on conflict (id) do update set public = true, file_size_limit = 52428800;

drop policy if exists acs_propagandas_insert on storage.objects;
create policy acs_propagandas_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'propagandas' and public.meu_papel() = 'admin');
drop policy if exists acs_propagandas_delete on storage.objects;
create policy acs_propagandas_delete on storage.objects for delete to authenticated
  using (bucket_id = 'propagandas' and public.meu_papel() = 'admin');

-- 5) Primeiro admin (precisa do PASSO 0 feito) + troca obrigatória de senha
insert into public.profiles (id, nome, usuario, role, ativo)
select id, 'Administrador', 'gestaomd', 'admin', true
from auth.users where email = 'gestaomd@seuapp.com'
on conflict (id) do update set role = 'admin', ativo = true, usuario = 'gestaomd';

update auth.users
set raw_user_meta_data = coalesce(raw_user_meta_data, '{}'::jsonb) || '{"trocar_senha": true}'::jsonb
where email = 'gestaomd@seuapp.com';
