function p = settings_articolato_4R()
    % SETTINGS_ARTICOLATO_4R Seconda prova di inseguimento a grande escursione.
    % Geometria, inerzie, controllo, gravita e tolleranze sono quelli nominali.
    p = settings_4R();
    % I periodi dividono tutti 12 s. Alla fine del ciclo ogni giunto ritrova
    % la posizione e la velocità desiderate dell’istante iniziale.
    p.tf = 12;                           % Un ciclo completo [s].
    p.qbar = [pi/2; 0.10; -0.15; 0];     % Posizione media dei giunti [rad].
    p.amp = [0.93; 1.18; 1.37; 1.45];   % Ampiezze angolari [rad].
    p.freq = 2*pi ./ [12; 6; 12; 4];     % Pulsazioni [rad/s].
    p.phase = [0; pi/4; 3*pi/4; -3*pi/4]; % Sfasamenti tra i quattro giunti.
    p.plot.tracceInterne = true;          % Mostra anche O1, O2, O3, errori e coppie.
    p.plot.durataScia = 0.8;             % Storia recente delle origini DH [s].
    p.plot.fps = 50;                     % Un fotogramma per campione da 0.02 s.
end
