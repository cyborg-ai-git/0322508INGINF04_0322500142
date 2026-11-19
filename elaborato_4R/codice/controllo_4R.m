function [tau, e] = controllo_4R(t, q, dq, p, M, C, G)
    % CONTROLLO_4R Coppia calcolata con retroazione PD e compensazione completa.
    % L’errore e = qd-q è positivo quando il riferimento precede il giunto.
    % q e dq diventano colonne per sottrarre angoli e velocità giunto per giunto.
    q = q(:);
    dq = dq(:);
    [qd, dqd, ddqd] = riferimento_4R(t, p);
    e = qd - q;
    % v è l’accelerazione richiesta [rad/s^2]. Ai termini proporzionale
    % e derivativo si somma l’accelerazione prevista dal riferimento.
    v = ddqd + p.Kd * (dqd - dq) + p.Kp * e;
    % La dinamica inversa converte v in coppie [N m]. Con il modello esatto
    % e coppie ideali, l’errore soddisfa e'' + Kd*e' + Kp*e = 0.
    tau = M * v + C * dq + G;
end
