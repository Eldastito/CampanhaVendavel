-- =====================================================================
-- Funções RPC do painel do organizador (painel.html).
-- SECURITY DEFINER para agregar telemetria mesmo com RLS restrito.
-- Recebem o slug do roteiro. Só authenticated pode executar.
-- =====================================================================

-- Resumo do funil (uma linha).
create or replace function public.roteiro_summary(env_slug text)
returns table (scans bigint, ar_opens bigint, completes bigint, redeems bigint, leads bigint, sessions bigint)
language sql
security definer
set search_path = public
as $$
  with env as (select id from public.environments where slug = env_slug)
  select
    (select count(*) from public.interaction_events e where e.environment_id = (select id from env) and e.kind = 'scan')     as scans,
    (select count(*) from public.interaction_events e where e.environment_id = (select id from env) and e.kind = 'ar_open')  as ar_opens,
    (select count(*) from public.interaction_events e where e.environment_id = (select id from env) and e.kind = 'complete') as completes,
    (select count(*) from public.interaction_events e where e.environment_id = (select id from env) and e.kind = 'redeem')   as redeems,
    (select count(*) from public.leads l                where l.environment_id = (select id from env))                       as leads,
    (select count(*) from public.participant_sessions s where s.environment_id = (select id from env))                       as sessions;
$$;

-- Estatísticas por ponto (uma linha por monumento/ponto).
create or replace function public.roteiro_node_stats(env_slug text)
returns table (label text, scans bigint, ar_opens bigint, completes bigint)
language sql
security definer
set search_path = public
as $$
  select n.label,
    count(*) filter (where e.kind = 'scan')     as scans,
    count(*) filter (where e.kind = 'ar_open')  as ar_opens,
    count(*) filter (where e.kind = 'complete') as completes
  from public.physical_nodes n
  join public.environments env on env.id = n.environment_id and env.slug = env_slug
  left join public.interaction_events e on e.node_id = n.id
  group by n.id, n.label, n.order_index
  order by n.order_index;
$$;

-- Visitas por dia (para o gráfico de barras). visitas = scans do dia.
create or replace function public.roteiro_daily(env_slug text)
returns table (dia date, visitas bigint)
language sql
security definer
set search_path = public
as $$
  select (e.created_at at time zone 'America/Sao_Paulo')::date as dia,
         count(*) as visitas
  from public.interaction_events e
  join public.environments env on env.id = e.environment_id and env.slug = env_slug
  where e.kind = 'scan'
  group by 1
  order by 1;
$$;

-- Lista de leads do roteiro (para tabela + CSV).
create or replace function public.leads_list(env_slug text)
returns table (name text, phone text, interest text, created_at timestamptz)
language sql
security definer
set search_path = public
as $$
  select l.name, l.phone, l.interest, l.created_at
  from public.leads l
  join public.environments env on env.id = l.environment_id and env.slug = env_slug
  order by l.created_at desc;
$$;

-- Permissões: só usuários autenticados executam.
revoke all on function public.roteiro_summary(text)    from public;
revoke all on function public.roteiro_node_stats(text)  from public;
revoke all on function public.roteiro_daily(text)       from public;
revoke all on function public.leads_list(text)          from public;
grant execute on function public.roteiro_summary(text)   to authenticated;
grant execute on function public.roteiro_node_stats(text) to authenticated;
grant execute on function public.roteiro_daily(text)      to authenticated;
grant execute on function public.leads_list(text)         to authenticated;
