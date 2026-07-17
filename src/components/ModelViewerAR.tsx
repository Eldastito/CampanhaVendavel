import React, { useEffect, useRef, useState } from 'react';

/**
 * ModelViewerAR — módulo de RA extraído e adaptado do livromagico
 * (ModelViewerDemo). Mostra um objeto/mascote 3D e abre a experiência de
 * RA nativa do aparelho no ponto (checkpoint).
 *
 * Diferença em relação ao original: aqui o `src` é usado direto (sem o
 * proxy `/api/proxy-model` do livromagico). Passe uma URL de proxy em
 * `proxyBase` se precisar contornar CORS dos modelos.
 *
 * Requer o script do model-viewer carregado (ver index.html):
 *   <script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"></script>
 * ...ou instale @google/model-viewer e importe-o no main.tsx.
 */
interface Props {
  /** GLB — usado por Android/WebXR/Scene Viewer */
  src: string;
  /** USDZ — usado pelo iOS (Quick Look) */
  iosSrc?: string;
  alt?: string;
  proxyBase?: string;
  onArActivate?: () => void;
}

function withProxy(url: string, proxyBase?: string): string {
  return proxyBase ? `${proxyBase}?url=${encodeURIComponent(url)}` : url;
}

export function ModelViewerAR({ src, iosSrc, alt = 'Modelo 3D', proxyBase, onArActivate }: Props) {
  const ref = useRef<HTMLElement>(null);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => setLoaded(false), [src]);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const onLoad = () => setLoaded(true);
    const onAr = () => onArActivate?.();
    el.addEventListener('load', onLoad);
    el.addEventListener('ar-status', onAr);
    const t = setTimeout(() => setLoaded(true), 1500); // fallback
    return () => {
      el.removeEventListener('load', onLoad);
      el.removeEventListener('ar-status', onAr);
      clearTimeout(t);
    };
  }, [src, onArActivate]);

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%', minHeight: 320 }}>
      {React.createElement(
        'model-viewer',
        {
          ref,
          src: withProxy(src, proxyBase),
          ...(iosSrc ? { 'ios-src': withProxy(iosSrc, proxyBase) } : {}),
          alt,
          ar: true,
          'ar-modes': 'webxr scene-viewer quick-look',
          'ar-scale': 'auto',
          'camera-controls': true,
          'auto-rotate': true,
          autoplay: true,
          'shadow-intensity': '1',
          'camera-orbit': '0deg 75deg 105%',
          style: { width: '100%', height: '100%' },
        },
        <button slot="ar-button" className="ar-button" type="button">
          Ver no meu espaço (RA)
        </button>,
      )}
      {!loaded && <div className="ar-loading" aria-hidden="true">Carregando 3D…</div>}
    </div>
  );
}
