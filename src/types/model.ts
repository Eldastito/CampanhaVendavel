/**
 * Modelo de dados — CampanhaVendavel
 * ------------------------------------------------------------------
 * O "keeper" da visão grande: as entidades nascem genéricas para que o
 * MVP (feira de mamãe e bebê) NÃO fique preso a uma feira específica, e
 * o mesmo motor sirva depois a shopping, museu, turismo, estádio, etc.
 *
 * Regra: nada de "Checkpoint". A unidade é um PhysicalNode — um nó do
 * mundo físico que pode ser loja, corredor, estande, monumento, fachada
 * ou produto. O que muda entre mercados é o conteúdo, não a estrutura.
 */

// ─────────────────────────────────────────────────────────────────────
// Tipos de apoio
// ─────────────────────────────────────────────────────────────────────

/** Como um nó físico é reconhecido/ancorado no mundo real. */
export type AnchorType =
  | 'qr'        // QR Code — abre a experiência (o mais barato e universal)
  | 'nfc'       // tag NFC — toque
  | 'image'     // image target (MindAR/AR.js) — âncora visual p/ 3D, roda no iPhone
  | 'gps'       // coordenada — ao ar livre
  | 'beacon'    // Bluetooth/beacon — proximidade indoor
  | 'manual';   // liberado pelo operador

/** O que acontece quando o visitante chega ao nó. */
export type ExperienceType =
  | 'save_item'   // salvar produto/loja (CAMP-01 "Meus Achados")
  | 'mission'     // missão/checkpoint gamificado (CAMP-02 "Passaporte")
  | 'quiz'
  | 'ar_model'    // mascote/objeto 3D via model-viewer
  | 'coupon'      // desbloqueia cupom
  | 'sampling'    // voucher de amostra rastreável (CAMP-03)
  | 'reward'      // recompensa/conquista
  | 'info';       // conteúdo/áudio/narração

/** Eventos de telemetria — o funil físico mensurável. */
export type InteractionKind =
  | 'scan'        // escaneou o nó
  | 'view'        // abriu a experiência
  | 'save'        // salvou item
  | 'arrive'      // confirmou chegada (retorno ao expositor)
  | 'complete'    // concluiu missão
  | 'redeem'      // resgatou cupom/voucher
  | 'lead'        // deixou contato (alimenta o ZappFlow)
  | 'ar_open';    // abriu a RA no ponto

export type AnchorConfig = {
  /** valor do QR/NFC, nome do image-target, ou lat/lng serializado */
  value: string;
  /** metadados livres por tipo de âncora (ex.: raio do beacon) */
  meta?: Record<string, string | number>;
};

export type Vec3 = { x: number; y: number; z: number };

// ─────────────────────────────────────────────────────────────────────
// As 8 entidades fundamentais
// ─────────────────────────────────────────────────────────────────────

/** O espaço: feira, andar de shopping, praça, mapa. */
export interface Environment {
  id: string;
  name: string;
  kind: 'fair' | 'mall' | 'museum' | 'outdoor' | 'stadium' | 'other';
  /** URL/asset do mapa base (planta, imagem, ou GeoJSON) */
  mapRef?: string;
  createdAt: string;
}

/** Um nó do mundo físico. Substitui o conceito de "checkpoint". */
export interface PhysicalNode {
  id: string;
  environmentId: string;
  type: 'store' | 'aisle' | 'booth' | 'landmark' | 'facade' | 'product' | 'point';
  label: string;
  anchorType: AnchorType;
  anchorConfig: AnchorConfig;
  /** posição no mapa/planta (opcional; nem todo nó tem coordenada) */
  position?: Vec3;
  /** experiências disponíveis neste nó */
  experienceIds: string[];
  /** regras de liberação (ordem, horário, pré-requisitos) */
  rules?: NodeRules;
}

export interface NodeRules {
  /** só libera após concluir estes nós (trilha ordenada) */
  requiresNodeIds?: string[];
  availableFrom?: string; // ISO
  availableTo?: string;   // ISO
  maxRedemptions?: number;
}

/** O que acontece no nó: missão, mascote, quiz, cupom, sampling... */
export interface Experience {
  id: string;
  nodeId: string;
  type: ExperienceType;
  title: string;
  body?: string;
  /** para type 'ar_model': GLB (Android/WebXR) + USDZ (iOS Quick Look) */
  modelGlbUrl?: string;
  modelUsdzUrl?: string;
  /** narração/áudio no ponto */
  audioUrl?: string;
  rewardId?: string;
}

/** Agrupa experiências + patrocinador + período. É o que se vende. */
export interface Campaign {
  id: string;
  environmentId: string;
  /** CAMP-01..04 do catálogo, ou custom */
  template: 'meus_achados' | 'passaporte' | 'sampling' | 'imobiliaria' | 'custom';
  name: string;
  sponsorIds: string[];
  nodeIds: string[];
  startAt: string;
  endAt: string;
  status: 'draft' | 'active' | 'ended';
}

/** O visitante na jornada. Consentimento é obrigatório (LGPD). */
export interface ParticipantSession {
  id: string;
  environmentId: string;
  /** anônimo por padrão; identifica só com opt-in explícito */
  anonId: string;
  consent: {
    analytics: boolean;
    marketing: boolean;
    grantedAt?: string;
  };
  startedAt: string;
  savedNodeIds: string[];
}

/** A telemetria: escaneou, salvou, chegou, resgatou. O ativo de dados. */
export interface InteractionEvent {
  id: string;
  sessionId: string;
  nodeId: string;
  experienceId?: string;
  kind: InteractionKind;
  campaignId?: string;
  at: string; // ISO timestamp
  meta?: Record<string, string | number | boolean>;
}

/** Cupom, brinde, conquista. */
export interface Reward {
  id: string;
  campaignId: string;
  type: 'coupon' | 'gift' | 'achievement' | 'raffle';
  label: string;
  /** código único p/ validação no estande (prova de resgate) */
  code?: string;
  maxUnits?: number;
  redeemedUnits: number;
}

/** Dono da cota patrocinada. Alimenta leads ao ZappFlow via API. */
export interface Sponsor {
  id: string;
  name: string;
  /** cota comprada: headline/mascote, checkpoint, recompensa */
  tier: 'headline' | 'checkpoint' | 'reward' | 'coop';
  logoUrl?: string;
  /** endpoint/identificador para empurrar leads ao ZappFlow */
  zappflowRef?: string;
}
