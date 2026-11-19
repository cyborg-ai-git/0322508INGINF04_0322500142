function [ruote, v, w] = ruote_da_twist(v, w, p)
    % RUOTE_DA_TWIST Inversione cinematica e saturazione che conserva la curvatura.
    % ruote=[omega_R;omega_L] [rad/s], ingressi v [m/s], w [rad/s].
    % Un comando di rotazione pura richiede ruote di uguale modulo e segno opposto.
    ruote = [(v + p.d * w / 2) / p.r; (v - p.d * w / 2) / p.r];
    % Se la ruota più veloce supera wheelMax, si riducono entrambe in
    % proporzione. I valori v e w restituiti descrivono il moto ottenibile.
    scala = max(1, max(abs(ruote)) / p.wheelMax);
    ruote = ruote / scala;
    v = p.r * (ruote(1) + ruote(2)) / 2;
    w = p.r * (ruote(1) - ruote(2)) / p.d;
end
