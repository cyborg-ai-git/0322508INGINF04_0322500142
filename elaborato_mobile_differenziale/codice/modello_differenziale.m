function dq = modello_differenziale(~, q, ruote, p)
    % MODELLO_DIFFERENZIALE Stato [x;y;theta], ingressi omega_R e omega_L.
    % ruote(1) è la velocità destra, ruote(2) la sinistra, entrambe in rad/s.
    % La media delle velocità periferiche dà v [m/s]. La differenza divisa
    % per la carreggiata d dà w [rad/s], positiva per una svolta antioraria.
    v = p.r * (ruote(1) + ruote(2)) / 2;
    w = p.r * (ruote(1) - ruote(2)) / p.d;
    dq = [v * cos(q(3)); v * sin(q(3)); w];
end
