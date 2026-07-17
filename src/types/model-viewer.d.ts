import * as React from 'react';

/**
 * Declaração JSX do custom element <model-viewer> (@google/model-viewer).
 * Extraído do livromagico. Habilita RA nativa: WebXR (Android Chrome),
 * Scene Viewer (Android) e Quick Look (iOS, via USDZ).
 */
declare global {
  namespace JSX {
    interface IntrinsicElements {
      'model-viewer': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement>,
        HTMLElement
      > & {
        src?: string;
        'ios-src'?: string;
        alt?: string;
        ar?: boolean;
        'ar-modes'?: string;
        'ar-scale'?: string;
        'camera-controls'?: boolean;
        'auto-rotate'?: boolean;
        autoplay?: boolean;
        'shadow-intensity'?: string;
        'camera-orbit'?: string;
        'camera-target'?: string;
      };
    }
  }
}

export {};
