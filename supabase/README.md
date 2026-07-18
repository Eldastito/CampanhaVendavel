# Backend Supabase — VivaAR

Este diretório **versiona o banco** para que ele seja reprodutível. Se o projeto
Supabase atual for perdido, dá para recriar tudo do zero com estes arquivos.

> ⚠️ Reconstruído a partir do código dos apps (não é um `pg_dump` byte-a-byte do
> projeto em produção). Cobre o essencial: tabelas, RLS, funções RPC e seed.
> Para uma cópia exata, gere um `pg_dump`/export no painel do Supabase.

## Conteúdo

```
supabase/
├── migrations/
│   ├── 0001_schema.sql   # tabelas + índices
│   ├── 0002_rls.sql      # Row Level Security (leitura pública, escrita autenticada)
│   └── 0003_rpcs.sql     # funções do painel (roteiro_summary, node_stats, daily, leads_list)
├── seed.sql              # organizador + 3 roteiros (rio-centro, estreia, encantada)
└── functions/
    └── generate-content/ # Edge Function (GPT principal + Gemini backup)
```

## Como recriar o banco num projeto novo

**Opção A — painel do Supabase (mais simples):**
1. Abra *SQL Editor* no projeto.
2. Rode, na ordem: `0001_schema.sql` → `0002_rls.sql` → `0003_rpcs.sql`.
3. Rode `seed.sql`.
4. Crie o usuário organizador em *Authentication → Users* (o e-mail precisa estar em `public.organizers`).

**Opção B — Supabase CLI:**
```bash
supabase link --project-ref <ref>
supabase db push          # aplica migrations/
supabase db seed          # aplica seed.sql (ou psql < seed.sql)
```

## Segredos (não versionados)

A Edge Function precisa destes segredos no projeto (Settings → Edge Functions):
`OPENAI_API_KEY`, `GEMINI_API_KEY`. Nunca comitar chaves no repositório.

## Depois de recriar

Atualize `SB_URL` e `SB_KEY` nos apps de `demo-roteiro/` (roteiro/painel/imovel/admin/qr)
para apontar ao novo projeto.
