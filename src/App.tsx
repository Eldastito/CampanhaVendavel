import { useState } from 'react';
import { ModelViewerAR } from './components/ModelViewerAR';
import type {
  Environment,
  PhysicalNode,
  Experience,
  Campaign,
  InteractionEvent,
} from './types/model';

/**
 * Demo mínima do MVP: uma feira com um nó ("Loja Baby Mais"), uma
 * experiência de RA (mascote) e o registro de telemetria ao interagir.
 * Serve para provar que o modelo de dados e o módulo de RA conversam.
 * Dados mock aqui — o backend real (Firebase/SQLite/Supabase) vem depois.
 */

const feira: Environment = {
  id: 'env_feira_bebe',
  name: 'Feira Mamãe & Bebê',
  kind: 'fair',
  createdAt: new Date().toISOString(),
};

const noLoja: PhysicalNode = {
  id: 'node_baby_mais',
  environmentId: feira.id,
  type: 'store',
  label: 'Loja Baby Mais',
  anchorType: 'qr',
  anchorConfig: { value: 'CV:node_baby_mais' },
  experienceIds: ['exp_mascote'],
};

const expMascote: Experience = {
  id: 'exp_mascote',
  nodeId: noLoja.id,
  type: 'ar_model',
  title: 'A cegonha te dá a próxima pista',
  body: 'Muito bem! Agora siga pela Rua Azul e procure o portal amarelo.',
  // Modelo 3D de exemplo (Astronaut — troque pelo mascote da feira)
  modelGlbUrl: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
  modelUsdzUrl: 'https://modelviewer.dev/shared-assets/models/Astronaut.usdz',
};

const campanha: Campaign = {
  id: 'camp_passaporte',
  environmentId: feira.id,
  template: 'passaporte',
  name: 'Passaporte do Bebê',
  sponsorIds: [],
  nodeIds: [noLoja.id],
  startAt: new Date().toISOString(),
  endAt: new Date(Date.now() + 864e5 * 3).toISOString(),
  status: 'active',
};

export function App() {
  const [events, setEvents] = useState<InteractionEvent[]>([]);

  function track(kind: InteractionEvent['kind']) {
    setEvents((prev) => [
      ...prev,
      {
        id: `evt_${prev.length + 1}`,
        sessionId: 'session_demo',
        nodeId: noLoja.id,
        experienceId: expMascote.id,
        campaignId: campanha.id,
        kind,
        at: new Date().toISOString(),
      },
    ]);
  }

  return (
    <main className="page">
      <header>
        <p className="eyebrow">{feira.name} · {campanha.name}</p>
        <h1>{noLoja.label}</h1>
        <p className="lede">{expMascote.title}</p>
      </header>

      <section className="stage" onClick={() => track('view')}>
        <ModelViewerAR
          src={expMascote.modelGlbUrl!}
          iosSrc={expMascote.modelUsdzUrl}
          alt="Mascote da feira"
          onArActivate={() => track('ar_open')}
        />
      </section>

      <p className="hint">{expMascote.body}</p>

      <div className="actions">
        <button onClick={() => track('save')}>Salvar loja</button>
        <button onClick={() => track('arrive')}>Confirmar chegada</button>
        <button onClick={() => track('redeem')}>Resgatar cupom</button>
      </div>

      <section className="telemetry">
        <h2>Telemetria ({events.length})</h2>
        <ul>
          {events.map((e) => (
            <li key={e.id}>
              <code>{e.kind}</code> · {new Date(e.at).toLocaleTimeString('pt-BR')}
            </li>
          ))}
          {events.length === 0 && <li className="muted">Interaja acima para gerar eventos.</li>}
        </ul>
      </section>
    </main>
  );
}
