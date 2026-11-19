function [libero, minimo] = segmento_libero(a, b, p, margine)
    % SEGMENTO_LIBERO Verifica l'intera traslazione del disco tra due pose.
    % Le rotazioni sul posto lasciano invariato il suo ingombro circolare.
    if nargin < 4
        margine = p.margin;
    end
    % minimo è il varco più piccolo lungo l’arco [m], incluso il margine
    % di pianificazione. Valori negativi indicano una sovrapposizione.
    minimo = distanza_libera(a, p, margine, b);
    libero = minimo > 0; % La tangenza al bordo o a un ostacolo e' esclusa.
end
