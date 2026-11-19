function p = settings_mobile()
    % SETTINGS_MOBILE Costanti del veicolo, della mappa, del PRM e del controllo.

    % Geometria e ambiente. Le pose sono colonne [x; y; theta] in m, m, rad.
    p.r = 0.07;                       % Raggio di ciascuna ruota [m].
    p.d = 0.32;                       % Distanza tra le ruote [m].
    p.robotRadius = 0.22;             % Raggio del disco circoscritto [m].
    p.margin = 0.18;                  % Margine addizionale del planner [m].
    p.bounds = [0 10 0 8];            % [xmin xmax ymin ymax] [m].
    p.obstacles = [3 2.5 0.8; 5 4 1; 7.4 5.8 0.8; 2.6 6 0.65]; % [x y R] [m].
    p.q0 = [0.8; 0.8; 0];             % Posa iniziale.
    p.qgoal = [9.2; 7.2; pi/2];       % Posa finale.

    % Il seme rende ripetibili le pose casuali. Raggio e numero di vicini
    % limitano le connessioni provate. Il costo di un arco è il tempo di moto.
    p.seed = 2025;                    % Seme del generatore di campioni.
    p.nSamples = 180;                 % Campioni liberi oltre a partenza e arrivo.
    p.neighbors = 14;                 % Numero massimo di vicini per nodo.
    p.maxSampleAttempts = 10000;      % Limite di estrazioni.
    p.connectionRadius = 3;           % Lunghezza massima di una connessione [m].
    p.vPlan = 0.45;                   % Velocita di avanzamento nominale [m/s].
    p.wPlan = 1.5;                    % Velocita di rotazione nominale [rad/s].
    p.referenceStep = 0.04;           % Passo massimo del riferimento [s].

    % Il controllo cambia waypoint entro posTol. Sull’ultimo punto
    % verifica anche angleTol prima di dichiarare raggiunta la posa finale.
    p.krho = 0.8;                     % Guadagno sulla distanza [1/s].
    p.kalpha = 3;                     % Guadagno di puntamento [1/s].
    p.ktheta = 3;                     % Guadagno di orientamento finale [1/s].
    p.vMax = 0.5;                     % Limite lineare [m/s].
    p.wMax = 1.8;                     % Limite angolare del corpo [rad/s].
    p.wheelMax = 12;                  % Limite per ogni ruota [rad/s].
    p.alignThreshold = 0.12;          % Soglia per iniziare l'avanzamento [rad].
    p.posTol = 0.025;                 % Tolleranza sul waypoint [m].
    p.angleTol = 0.015;               % Tolleranza sull'angolo di arrivo [rad].
    p.dt = 0.02;                      % Periodo di aggiornamento delle ruote [s].
    p.ode.relTol = 1e-8;              % Tolleranza relativa del solutore.
    p.ode.absTol = 1e-10;             % Tolleranza assoluta sulle tre coordinate.
    p.maxTime = 300;                  % Tempo massimo della simulazione [s].

    % Tolleranze numeriche delle primitive e margine per passo integrato.
    p.num.smallAngle = 1e-8;          % Soglia per la serie di sinc [rad].
    p.num.zeroLength = 1e-12;         % Segmento di lunghezza trascurabile [m].
    p.num.zeroTime = 1e-12;           % Durata di primitiva trascurabile [s].
    p.num.endPosition = 1e-8;         % Precisione richiesta agli estremi [m].
    p.num.endAngle = 1e-8;            % Precisione angolare agli estremi [rad].
    p.num.clearance = 1e-8;           % Margine numerico sul passo [m].

    % Visualizzazione ed esportazione.
    p.plot.window = [100 100 900 650]; % Rettangolo della figura [pixel].
    p.plot.resolution = '-r150';       % Risoluzione PNG [dpi].
    p.plot.mapPoints = 100;            % Campioni per i cerchi della mappa.
    p.plot.bodyPoints = 50;            % Campioni per il corpo animato.
    p.plot.videoWindow = [40 40 1080 620]; % Dimensione della scena [pixel].
    p.plot.fps = 25;                   % Fotogrammi al secondo del filmato.
    p.plot.videoSpeed = 4;             % Secondi simulati per secondo di video.
end
