-- =====================================================================
-- VivaAR — Schema base (reconstruído a partir do código dos apps).
-- Reproduzível: rode em qualquer projeto Supabase novo para recriar o banco.
-- NÃO é um dump byte-a-byte do projeto atual; é a estrutura que os apps usam.
-- =====================================================================

create extension if not exists pgcrypto;   -- gen_random_uuid()

-- ---------------------------------------------------------------------
-- Ambientes (roteiros / campanhas). 1 slug = 1 experiência pública.
-- ---------------------------------------------------------------------
create table if not exists public.environments (
  id           uuid primary key default gen_random_uuid(),
  slug         text unique not null,
  name         text not null,
  kind         text not null default 'tourism',   -- tourism | museum | mall | fair | real_estate ...
  reward_title text,
  reward_code  text,
  cta_label    text,
  cta_url      text,
  created_at   timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- Patrocinadores (marcas). Ligados a pontos via physical_nodes.sponsor_id.
-- ---------------------------------------------------------------------
create table if not exists public.sponsors (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  logo_url   text,
  message    text,
  cta_label  text default 'Quero esta oferta',
  cta_url    text,
  tier       text default 'checkpoint',
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- Pontos físicos (paradas do roteiro). anchor_value = CV:<slug>:<code>.
-- ---------------------------------------------------------------------
create table if not exists public.physical_nodes (
  id             uuid primary key default gen_random_uuid(),
  environment_id uuid not null references public.environments(id) on delete cascade,
  label          text not null,
  subtitle       text,
  anchor_value   text,                 -- ex.: CV:encantada:escada  (o code é o último segmento)
  order_index    int not null default 1,
  sponsor_id     uuid references public.sponsors(id) on delete set null,
  created_at     timestamptz not null default now()
);
create index if not exists idx_nodes_env on public.physical_nodes(environment_id, order_index);

-- ---------------------------------------------------------------------
-- Experiências (conteúdo 3D/RA + texto de cada ponto). 1:N por ponto,
-- mas os apps usam a primeira. data (jsonb): flabel, chips[], curios[], note.
-- ---------------------------------------------------------------------
create table if not exists public.experiences (
  id             uuid primary key default gen_random_uuid(),
  node_id        uuid not null references public.physical_nodes(id) on delete cascade,
  title          text,
  body           text,
  model_glb_url  text,
  model_usdz_url text,
  data           jsonb not null default '{}'::jsonb,
  created_at     timestamptz not null default now()
);
create index if not exists idx_exp_node on public.experiences(node_id);

-- ---------------------------------------------------------------------
-- Sessões anônimas de visitante (telemetria).
-- ---------------------------------------------------------------------
create table if not exists public.participant_sessions (
  id                uuid primary key default gen_random_uuid(),
  environment_id    uuid references public.environments(id) on delete cascade,
  anon_id           text,
  consent_analytics boolean not null default false,
  created_at        timestamptz not null default now()
);
create index if not exists idx_sessions_env on public.participant_sessions(environment_id);

-- ---------------------------------------------------------------------
-- Eventos de interação (funil). kind: scan | ar_open | complete | redeem | lead | sponsor.
-- ---------------------------------------------------------------------
create table if not exists public.interaction_events (
  id             uuid primary key default gen_random_uuid(),
  session_id     uuid references public.participant_sessions(id) on delete set null,
  environment_id uuid references public.environments(id) on delete cascade,
  node_id        uuid references public.physical_nodes(id) on delete set null,
  kind           text not null,
  created_at     timestamptz not null default now()
);
create index if not exists idx_events_env  on public.interaction_events(environment_id, kind);
create index if not exists idx_events_node on public.interaction_events(node_id, kind);
create index if not exists idx_events_day  on public.interaction_events(environment_id, created_at);

-- ---------------------------------------------------------------------
-- Leads (captura consentida — vertical imobiliária e afins).
-- ---------------------------------------------------------------------
create table if not exists public.leads (
  id             uuid primary key default gen_random_uuid(),
  environment_id uuid references public.environments(id) on delete cascade,
  node_id        uuid references public.physical_nodes(id) on delete set null,
  sponsor_id     uuid references public.sponsors(id) on delete set null,
  name           text,
  phone          text,
  interest       text,
  consent        boolean not null default false,
  created_at     timestamptz not null default now()
);
create index if not exists idx_leads_env on public.leads(environment_id, created_at);

-- ---------------------------------------------------------------------
-- Organizadores autorizados (allowlist usada pela Edge Function generate-content).
-- ---------------------------------------------------------------------
create table if not exists public.organizers (
  email      text primary key,
  created_at timestamptz not null default now()
);
