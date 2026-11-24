-- Gestão ACS Saúde — área do agente de saúde (1º script, depois do setup.sql).
-- Pode rodar mais de uma vez sem erro.

create or replace function public.meu_papel()
returns text language sql stable security definer set search_path = public as $$
  select role from public.profiles where id = auth.uid() and ativo
$$;

-- ===== Famílias =====
create table if not exists public.acs_familias (
  id uuid primary key default gen_random_uuid(),
  agente_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  responsavel text not null,
  logradouro text not null,
  created_at timestamptz not null default now()
);
alter table public.acs_familias add column if not exists telefone text;
alter table public.acs_familias add column if not exists numero text;
alter table public.acs_familias add column if not exists bairro text;
alter table public.acs_familias add column if not exists complemento text;
alter table public.acs_familias add column if not exists microarea text;
alter table public.acs_familias add column if not exists moradia text;
alter table public.acs_familias add column if not exists agua text;
alter table public.acs_familias add column if not exists esgoto text;
alter table public.acs_familias add column if not exists lixo text;
alter table public.acs_familias add column if not exists energia boolean not null default true;
alter table public.acs_familias add column if not exists animais boolean not null default false;
alter table public.acs_familias add column if not exists renda text;
alter table public.acs_familias add column if not exists observacao text;

-- ===== Membros (pessoas) =====
create table if not exists public.acs_membros (
  id uuid primary key default gen_random_uuid(),
  agente_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  familia_id uuid not null references public.acs_familias(id) on delete cascade,
  nome text not null,
  created_at timestamptz not null default now()
);
alter table public.acs_membros add column if not exists nascimento date;
alter table public.acs_membros add column if not exists sexo text;
alter table public.acs_membros add column if not exists cpf text;
alter table public.acs_membros add column if not exists cartao_sus text;
alter table public.acs_membros add column if not exists parentesco text;
alter table public.acs_membros add column if not exists escolaridade text;
alter table public.acs_membros add column if not exists ocupacao text;
alter table public.acs_membros add column if not exists gestante boolean not null default false;
alter table public.acs_membros add column if not exists doencas text[] not null default '{}';
alter table public.acs_membros add column if not exists outras_doencas text;
alter table public.acs_membros add column if not exists medicamentos text;
alter table public.acs_membros add column if not exists observacao text;

-- ===== Catálogo de vacinas =====
create table if not exists public.acs_vacinas_tipos (
  id uuid primary key default gen_random_uuid(),
  agente_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  nome text not null,
  created_at timestamptz not null default now()
);
alter table public.acs_vacinas_tipos add column if not exists descricao text;
create unique index if not exists acs_vacinas_tipos_nome_uk on public.acs_vacinas_tipos (agente_id, nome);

-- ===== Vacinas das pessoas =====
create table if not exists public.acs_vacinas (
  id uuid primary key default gen_random_uuid(),
  agente_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  membro_id uuid not null references public.acs_membros(id) on delete cascade,
  tipo_id uuid not null references public.acs_vacinas_tipos(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.acs_vacinas add column if not exists status text not null default 'agendada'
  check (status in ('agendada', 'concluida'));
alter table public.acs_vacinas add column if not exists data_prevista date;
alter table public.acs_vacinas add column if not exists aplicada_em date;
alter table public.acs_vacinas add column if not exists aplicado_por text;
alter table public.acs_vacinas add column if not exists lote text;
create unique index if not exists acs_vacinas_membro_tipo_uk on public.acs_vacinas (membro_id, tipo_id);

-- ===== Visitas =====
create table if not exists public.acs_visitas (
  id uuid primary key default gen_random_uuid(),
  agente_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  familia_id uuid not null references public.acs_familias(id) on delete restrict,
  agendada_para timestamptz not null,
  motivo text not null,
  created_at timestamptz not null default now()
);
alter table public.acs_visitas add column if not exists status text not null default 'agendada'
  check (status in ('agendada', 'concluida', 'nao_realizada'));
alter table public.acs_visitas add column if not exists justificativa text;
alter table public.acs_visitas add column if not exists concluida_em timestamptz;
alter table public.acs_visitas add column if not exists questionario jsonb;

create index if not exists acs_membros_familia_idx on public.acs_membros (familia_id);
create index if not exists acs_visitas_agente_idx on public.acs_visitas (agente_id, agendada_para);

alter table public.acs_familias enable row level security;
alter table public.acs_membros enable row level security;
alter table public.acs_vacinas_tipos enable row level security;
alter table public.acs_vacinas enable row level security;
alter table public.acs_visitas enable row level security;

-- ===== Regras: cada agente vê e altera só os próprios dados; gestão e admin só leem =====
drop policy if exists acs_familias_select on public.acs_familias;
create policy acs_familias_select on public.acs_familias for select to authenticated
  using (agente_id = auth.uid() or public.meu_papel() in ('gestao', 'admin'));
drop policy if exists acs_familias_escrita on public.acs_familias;
create policy acs_familias_escrita on public.acs_familias for all to authenticated
  using (agente_id = auth.uid() and public.meu_papel() = 'agente')
  with check (agente_id = auth.uid() and public.meu_papel() = 'agente');

drop policy if exists acs_membros_select on public.acs_membros;
create policy acs_membros_select on public.acs_membros for select to authenticated
  using (agente_id = auth.uid() or public.meu_papel() in ('gestao', 'admin'));
drop policy if exists acs_membros_escrita on public.acs_membros;
create policy acs_membros_escrita on public.acs_membros for all to authenticated
  using (agente_id = auth.uid() and public.meu_papel() = 'agente')
  with check (agente_id = auth.uid() and public.meu_papel() = 'agente');

drop policy if exists acs_vacinas_tipos_select on public.acs_vacinas_tipos;
create policy acs_vacinas_tipos_select on public.acs_vacinas_tipos for select to authenticated
  using (agente_id = auth.uid() or public.meu_papel() in ('gestao', 'admin'));
drop policy if exists acs_vacinas_tipos_escrita on public.acs_vacinas_tipos;
create policy acs_vacinas_tipos_escrita on public.acs_vacinas_tipos for all to authenticated
  using (agente_id = auth.uid() and public.meu_papel() = 'agente')
  with check (agente_id = auth.uid() and public.meu_papel() = 'agente');

drop policy if exists acs_vacinas_select on public.acs_vacinas;
create policy acs_vacinas_select on public.acs_vacinas for select to authenticated
  using (agente_id = auth.uid() or public.meu_papel() in ('gestao', 'admin'));
drop policy if exists acs_vacinas_escrita on public.acs_vacinas;
create policy acs_vacinas_escrita on public.acs_vacinas for all to authenticated
  using (agente_id = auth.uid() and public.meu_papel() = 'agente')
  with check (agente_id = auth.uid() and public.meu_papel() = 'agente');

-- Visitas: sem regra de exclusão (não podem ser apagadas) e,
-- depois de concluída ou justificada, não podem mais ser alteradas.
drop policy if exists acs_visitas_select on public.acs_visitas;
create policy acs_visitas_select on public.acs_visitas for select to authenticated
  using (agente_id = auth.uid() or public.meu_papel() in ('gestao', 'admin'));

drop policy if exists acs_visitas_insert on public.acs_visitas;
create policy acs_visitas_insert on public.acs_visitas for insert to authenticated
  with check (agente_id = auth.uid() and public.meu_papel() = 'agente' and status = 'agendada');

drop policy if exists acs_visitas_update on public.acs_visitas;
create policy acs_visitas_update on public.acs_visitas for update to authenticated
  using (agente_id = auth.uid() and public.meu_papel() = 'agente' and status = 'agendada')
  with check (agente_id = auth.uid() and public.meu_papel() = 'agente');
