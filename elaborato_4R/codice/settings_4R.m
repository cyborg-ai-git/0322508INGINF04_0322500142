function p = settings_4R()
    % SETTINGS_4R Costanti del modello, del riferimento e della simulazione.
    % Tutti i vettori articolari sono colonne in ordine dalla base alla punta.

    % Geometria e masse di aste uniformi nel piano verticale (unita SI).
    p.L = [0.8; 0.65; 0.5; 0.35];     % Lunghezze [m].
    p.m = [2; 1.5; 1; 0.6];           % Masse [kg].
    p.c = p.L / 2;                    % Distanze dei baricentri [m].
    p.I = p.m .* p.L.^2 / 12;         % Inerzie baricentriche [kg m^2].
    p.g = 9.81;                       % Modulo della gravita lungo -y [m/s^2].

    % Con Kp=64 e Kd=16 ogni giunto ha due poli in -8 1/s. L’offset
    % perturba la posa iniziale e rende visibile il recupero del riferimento.
    p.Kp = diag([64 64 64 64]);       % Guadagni di posizione [1/s^2].
    p.Kd = diag([16 16 16 16]);       % Guadagni di velocita [1/s].
    p.qbar = [0.3; 0.8; -0.6; 0.2];   % Posizioni medie [rad].
    p.amp = [0.20; 0.16; 0.12; 0.10]; % Ampiezze [rad].
    p.freq = 2 * pi ./ [10; 8; 12; 9];  % Quattro pulsazioni [rad/s].
    p.phase = [0; pi/4; pi/2; -pi/3];   % Fasi [rad].
    p.offset = [0.12; -0.10; 0.08; -0.06]; % Perturbazione iniziale [rad].

    % Integrazione, cinematica inversa e finestra di analisi.
    p.tf = 10;                        % Durata complessiva [s].
    p.dt = 0.02;                      % Intervallo tra campioni restituiti [s].
    p.ode.relTol = 1e-8;              % Tolleranza relativa di ode45.
    p.ode.absTol = 1e-10;             % Tolleranza assoluta di ode45.
    p.ode.maxStep = 0.02;             % Passo interno massimo [s].
    p.ikTol = 1e-10;                  % Tolleranza relativa di raggiungibilita.
    p.singularTol = 1e-9;             % Soglia su 1 - abs(cos(q2)).

    % Visualizzazione ed esportazione.
    p.plot.window = [100 100 900 650]; % Posizione e dimensioni [pixel].
    p.plot.resolution = '-r150';       % Risoluzione PNG [dpi].
    p.plot.frameScale = 0.12;          % Lunghezza delle frecce DH [m].
    p.plot.staticMargin = 0.18;        % Margine attorno al disegno [m].
    p.plot.replayMargin = 0.20;        % Margine della finestra animata [m].
    p.plot.videoWindow = [40 40 1080 620]; % Dimensione della scena [pixel].
    p.plot.fps = 25;                   % Fotogrammi al secondo del filmato.
    p.plot.videoSpeed = 1;             % Secondi simulati per secondo di video.
end
