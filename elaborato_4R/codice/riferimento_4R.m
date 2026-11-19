function [qd, dqd, ddqd] = riferimento_4R(t, p)
    % RIFERIMENTO_4R Traiettoria sinusoidale regolare nello spazio dei giunti.
    % qd, dqd e ddqd sono posizione, velocità e accelerazione desiderate.
    % Ogni riga descrive un giunto. Per un vettore t, la colonna k corrisponde
    % a t(k). La derivazione analitica fornisce il termine usato dal controllore.
    omega = p.freq(:);
    amp = p.amp(:);
    a = omega * t(:).' + p.phase(:);
    qd = p.qbar(:) + amp .* sin(a);
    dqd = amp .* omega .* cos(a);
    ddqd = -amp .* omega.^2 .* sin(a);
end
