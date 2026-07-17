# CampanhaVendavel

Plataforma de **jornadas gamificadas para espaços físicos** — conecta visitantes,
marcas, pontos de interesse e recompensas por meio de mapas, QR Codes, NFC e
realidade aumentada. Ferramenta de marketing de experiência que **aumenta
circulação, retorno e conversão** em feiras e eventos.

> Não vendemos realidade aumentada. Vendemos circulação, retorno e conversão —
> provados com dados. A RA entra como encantamento nos pontos, nunca como a
> promessa principal.

## Estratégia (resumo)

- **Primeiro mercado:** feiras e eventos com muitos expositores.
- **Primeiro comprador:** o organizador — que revende cotas de patrocínio.
- **Métrica-mãe:** % de visitantes que retornam ao expositor após salvar uma oferta.
- **Frente vertical, arquitetura horizontal:** o modelo de dados nasce genérico
  (`PhysicalNode`), para o mesmo motor servir feira, shopping, museu, turismo, etc.

O detalhamento comercial está em [`docs/catalogo-campanhas.html`](docs/catalogo-campanhas.html)
e os princípios/limites de escopo em [`docs/PRINCIPIOS.md`](docs/PRINCIPIOS.md).

## O que já tem aqui (scaffold inicial)

| Peça | Onde | Origem |
|------|------|--------|
| Modelo de dados (8 entidades) | `src/types/model.ts` | novo — o "keeper" da visão |
| Módulo de RA (model-viewer) | `src/components/ModelViewerAR.tsx` | extraído do `livromagico` |
| Declaração JSX do `<model-viewer>` | `src/types/model-viewer.d.ts` | extraído do `livromagico` |
| Demo (feira + nó + RA + telemetria) | `src/App.tsx` | novo |
| Catálogo de campanhas | `docs/` | novo |

## Rodar localmente

**Pré-requisito:** Node.js 18+

```bash
npm install
npm run dev
```

Abra o endereço que o Vite mostrar (ex.: `http://localhost:5173`).
Para testar a RA, acesse por **HTTPS em um celular** (a câmera exige contexto seguro).

## Próximos passos (roadmap curto)

1. Backend das 8 entidades (Firebase, Supabase ou SQLite — a decidir).
2. Leitura de QR (`html5-qrcode`) e mapa — a portar do `cacadortesouro`.
3. RA por imagem (MindAR) para ancorar 3D em marcador — roda no iPhone.
4. Painel do organizador (telemetria por marca) — o que renova contrato.

## Escopo — o que **não** entra agora

Simulação operacional de multidão, marketplace self-service, "Behavior
Intelligence" como produto, fusão com o ZappFlow (integra por API), VPS próprio,
começar por estádio. Ver [`docs/PRINCIPIOS.md`](docs/PRINCIPIOS.md).
