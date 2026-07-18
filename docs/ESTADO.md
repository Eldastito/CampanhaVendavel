# VivaAR / CampanhaVendavel — Estado do projeto

_Última atualização: 2026-07-18_

Ponto de retomada rápido. Se você abrir uma sessão nova, comece lendo este arquivo.

## O que é, onde roda

- **Repositório único**: `Eldastito/CampanhaVendavel` (branch `main`).
- **Deploy automático**: cada push na `main` → Netlify republica **https://vivaar.netlify.app**.
- **Pasta publicada**: `demo-roteiro/` (definido em `netlify.toml`, `publish = "demo-roteiro"`).
- **Backend**: Supabase (projeto `uhyzpmzxkgprjevnojpf`). Auth por e-mail, Postgres, 1 Edge Function.
- **Login organizador**: `eldastito@gmail.com` / senha definida no Supabase (não versionada aqui).

> Observação importante: o produto real são os apps HTML de arquivo único em `demo-roteiro/`.
> A pasta `src/` (React/TS/Vite) é um scaffold antigo **não usado** — não é deployado.

## Apps publicados (em `demo-roteiro/`)

| Arquivo | Função | Acesso |
|---|---|---|
| `index.html` | Vitrine / landing (scroll 3D, porta de entrada) | `/` |
| `roteiro.html` | Experiência do visitante (RA + narração + passaporte + brinde). Multi-roteiro via `?r=slug` | `/roteiro.html?r=SLUG` |
| `imovel.html` | Vertical imobiliária (casa em RA + captura de lead) | `/imovel.html` |
| `painel.html` | Painel do organizador (login + KPIs + funil + leads + CSV) | `/painel.html` |
| `admin.html` | CRUD no-code de roteiros/pontos/patrocinadores + geração de conteúdo por IA | `/admin.html` |
| `qr.html` | Gera QR por roteiro e **copia link para gravar em tag NFC** | `/qr.html` |

Libs vendorizadas localmente (sem CDN, para não dar tela preta): `model-viewer.min.js`, `supabase.js`, `qrcode.js`.

## Roteiros cadastrados no banco

| slug | Nome | Pontos | Modelos | Status |
|---|---|---|---|---|
| `rio-centro` | Roteiro Cultural — Centro do Rio | teatro, pegaso, pietat | reais | pronto |
| `estreia` | Estreia — Caça aos Heróis (cinema) | heroi1, heroi2, heroi3 | **placeholder** (pegasus) | demo pronta; personagens placeholder por direitos Marvel |
| `encantada` | A Encantada — Santos Dumont | escada, interior, foto | **placeholder** (pegasus) | roteiro pronto; faltam modelos reais |

Colunas de brinde por campanha em `environments`: `reward_title`, `reward_code`, `cta_label`, `cta_url`.

## Assets 3D pendentes (a criar/subir)

- [ ] **14 Bis** (`.glb` + `.usdz`) → ponto `foto` do roteiro `encantada`.
- [ ] **Personagem Santos Dumont** (`.glb` + `.usdz`) → pontos `escada` e `interior` do `encantada`.
- [ ] Personagens reais do filme (só com licença do estúdio) → roteiro `estreia`.
- Ao subir: escala ~1,2 m "maquete" (GLB via nó pai; USDZ via `metersPerUnit`), como no teatro.

## Configurações que ainda dependem de você

- Site real do museu → `environments.cta_url` do `encantada` (hoje `exemplo-museu.com`).
- URL real da pré-venda → `environments.cta_url` do `estreia` (hoje `exemplo-cinema.com`).
- Segredos da Edge Function no Supabase: `OPENAI_API_KEY` e `GEMINI_API_KEY` (para o "Gerar com IA" do admin). **Nunca colocar chave no chat/repo.**
- Aprovação da direção do Museu Casa de Santos Dumont antes de teste presencial.

## Dívidas técnicas conhecidas (ver avaliação em docs/AVALIACAO-CONSOLIDACAO.md quando existir)

1. **Banco não versionado** (risco alto): schema, RPCs e RLS existem só no projeto Supabase, não há `supabase/migrations` nem `seed.sql`. Se o projeto sumir, não há como reconstruir.
2. **Consentimento LGPD** no roteiro cultural: hoje a sessão é criada com `consent_analytics: true` sem perguntar.
3. **Sessão/progresso não persistem**: a cada refresh cria-se um "novo visitante"; selos não sobrevivem ao recarregar.
4. **QR/Studio**: `qr.html` usa listas fixas por roteiro (não lê do banco). `admin.html` já faz CRUD, mas sem upload de modelos.

## Próximo passo sugerido

Fechar o **teste do cinema** (receita imediata) e, em paralelo, atacar a dívida #1 (versionar o banco). Detalhes e prioridação na avaliação abaixo.
