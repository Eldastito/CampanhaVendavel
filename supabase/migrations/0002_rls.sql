-- =====================================================================
-- RLS (Row Level Security).
-- Modelo: conteúdo do roteiro é PÚBLICO para leitura (o app do visitante é
-- anônimo). O visitante pode INSERIR telemetria e leads. Só usuários
-- autenticados (organizadores) podem gerenciar conteúdo e LER telemetria/leads.
-- A Edge Function usa a service role, que ignora RLS.
-- =====================================================================

alter table public.environments        enable row level security;
alter table public.sponsors            enable row level security;
alter table public.physical_nodes      enable row level security;
alter table public.experiences         enable row level security;
alter table public.participant_sessions enable row level security;
alter table public.interaction_events  enable row level security;
alter table public.leads               enable row level security;
alter table public.organizers          enable row level security;

-- ---- Conteúdo público: leitura para todos (anon + authenticated) ----
create policy "public read environments"   on public.environments   for select using (true);
create policy "public read sponsors"        on public.sponsors        for select using (true);
create policy "public read nodes"           on public.physical_nodes  for select using (true);
create policy "public read experiences"     on public.experiences     for select using (true);

-- ---- Conteúdo: escrita só para autenticados (organizadores) ----
create policy "auth write environments" on public.environments  for all to authenticated using (true) with check (true);
create policy "auth write sponsors"      on public.sponsors       for all to authenticated using (true) with check (true);
create policy "auth write nodes"         on public.physical_nodes for all to authenticated using (true) with check (true);
create policy "auth write experiences"   on public.experiences    for all to authenticated using (true) with check (true);

-- ---- Telemetria: visitante anônimo INSERE; organizador LÊ ----
create policy "anon insert sessions" on public.participant_sessions for insert to anon, authenticated with check (true);
create policy "auth read sessions"   on public.participant_sessions for select to authenticated using (true);

create policy "anon insert events" on public.interaction_events for insert to anon, authenticated with check (true);
create policy "auth read events"   on public.interaction_events for select to authenticated using (true);

-- ---- Leads: visitante anônimo INSERE (formulário); organizador LÊ ----
create policy "anon insert leads" on public.leads for insert to anon, authenticated with check (true);
create policy "auth read leads"   on public.leads for select to authenticated using (true);

-- ---- Organizers: sem acesso anônimo. Leitura para autenticados; escrita
--      fica com a service role (sem policy = negado para anon/authenticated). ----
create policy "auth read organizers" on public.organizers for select to authenticated using (true);
