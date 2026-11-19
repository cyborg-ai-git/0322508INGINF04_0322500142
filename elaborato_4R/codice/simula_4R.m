function out = simula_4R(p)
    % SIMULA_4R Esegue ode45, ricostruisce riferimenti, coppie ed errori.
    if nargin < 1
        p = settings_4R();
    end
    [qd0, dqd0] = riferimento_4R(0, p);
    z0 = [qd0 + p.offset(:); dqd0]; % Errore di velocita iniziale nullo, posizione non nulla.
    % Usa i valori di configurazione anche con parametri salvati in precedenza.
    cfg = settings_4R();
    if isfield(p, 'ode')
        cfg.ode = p.ode;
    end
    options = odeset('RelTol', cfg.ode.relTol, 'AbsTol', cfg.ode.absTol, ...
                     'MaxStep', cfg.ode.maxStep);
    validateattributes(p.dt, {'numeric'}, {'scalar', 'real', 'finite', 'positive'});
    validateattributes(p.tf, {'numeric'}, {'scalar', 'real', 'finite', 'positive'});
    % Conserva l'ultimo intervallo anche se la durata non e' multipla del passo.
    tempi = (0:p.dt:p.tf).';
    if tempi(end) < p.tf
        tempi(end + 1, 1) = p.tf;
    end
    % tempi stabilisce dove restituire gli stati per grafici e confronti.
    % ode45 sceglie separatamente i suoi passi interni con le tolleranze date.
    [t, z] = ode45(@(t, z) modello_4R(t, z, p), tempi, z0, options);
    if numel(tempi) == 2
        % Con due soli estremi ode45 restituisce anche i suoi passi interni.
        t = t([1 end]);
        z = z([1 end], :);
    end
    n = numel(t);
    qd = zeros(n, 4);
    tau = qd;
    ee = zeros(n, 2);
    target = ee;
    % Per ogni stato restituito si ricalcola la coppia del controllore.
    % La cinematica diretta di q e qr dà punta simulata e bersaglio in metri.
    for k = 1:n
        q = z(k, 1:4).';
        dq = z(k, 5:8).';
        [qr, ~, ~] = riferimento_4R(t(k), p);
        qd(k, :) = qr.';
        [M, C, G] = dynamics_4R(q, dq, p);
        tau(k, :) = controllo_4R(t(k), q, dq, p, M, C, G).';
        [~, x, y] = fk_4R(q, p.L);
        ee(k, :) = [x, y];
        [~, x, y] = fk_4R(qr, p.L);
        target(k, :) = [x, y];
    end
    e = qd - z(:, 1:4);
    out = struct('t', t, 'q', z(:, 1:4), 'dq', z(:, 5:8), 'qd', qd, 'e', e, ...
               'tau', tau, 'ee', ee, 'target', target, 'p', p);
    % L’RMS è calcolato sui campioni di ogni giunto. L’errore cartesiano
    % usa la distanza euclidea tra punta e bersaglio allo stesso istante.
    out.metriche = struct('rms_giunti', sqrt(mean(e.^2)), ...
                        'errore_finale', max(abs(e(end, :))), 'coppia_picco', max(abs(tau)), ...
                        'errore_cartesiano_max', max(sqrt(sum((ee - target).^2, 2))), ...
                        'errore_dopo_2s', NaN);
    if t(end) >= 2
        out.metriche.errore_dopo_2s = max(max(abs(e(t >= 2, :))));
    end
end
