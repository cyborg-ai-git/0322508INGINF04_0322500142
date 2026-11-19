function out = simula_mobile(plan, p)
    % SIMULA_MOBILE Controllo a waypoint, ode45 e certificazione collisioni per passo.
    % La posa viene misurata all’inizio del passo. Il controllo sceglie le
    % velocità delle ruote e le mantiene costanti fino al campione seguente.
    % Il tratto percorso dal centro è lungo |v|*dt. La distanza libera può
    % ridursi al più di questa quantità, anche durante una curva.
    % Compatibilita con strutture di simulazione salvate prima dei settings.
    if ~isfield(p, 'num')
        cfg = settings_mobile();
        p.num = cfg.num;
    end
    if ~isfield(p, 'ode')
        cfg = settings_mobile();
        p.ode = cfg.ode;
    end
    opzioni = odeset('RelTol', p.ode.relTol, 'AbsTol', p.ode.absTol);
    validateattributes(p.dt, {'numeric'}, {'scalar', 'real', 'finite', 'positive'});
    validateattributes(p.maxTime, {'numeric'}, {'scalar', 'real', 'finite', 'positive'});
    % Conserva i tempi di campionamento e include una sola volta il timeout.
    t = (0:floor(p.maxTime / p.dt)).' * p.dt;
    t = t(t < p.maxTime);
    t(end + 1, 1) = p.maxTime;
    N = numel(t);
    Q = zeros(N, 3);
    U = zeros(N, 2);
    vw = zeros(N, 2);
    rho = zeros(N, 1);
    alpha = rho;
    mode = rho;
    idx = rho;
    clearance = rho;
    q = p.q0;
    wp = plan.waypoints;
    % Il primo waypoint coincide con la partenza. Il primo bersaglio
    % del controllore è quindi la seconda posa del percorso.
    active = 2;
    finito = false;
    for k = 1:N
        % Si passa al prossimo target solo entro la tolleranza di quello corrente.
        while active < size(wp, 1) && norm(q(1:2) - wp(active, 1:2).') <= p.posTol
            active = active + 1;
        end
        [u, rr, aa, md, v, w] = controllo_mobile(q, wp(active, :).', p, active == size(wp, 1));
        % Sulla stessa riga si salva la posa al tempo t(k) e il comando che
        % verrà applicato da quella posa fino al campione successivo.
        Q(k, :) = q.';
        U(k, :) = u.';
        rho(k) = rr;
        alpha(k) = aa;
        mode(k) = md;
        idx(k) = active;
        vw(k, :) = [v w];
        clearance(k) = distanza_libera(q, p, 0);
        if active == size(wp, 1) && rr <= p.posTol ...
                && abs(angolo_pi(q(3) - p.qgoal(3))) <= p.angleTol
            finito = true;
            U(k, :) = [0 0];
            vw(k, :) = [0 0];
            break
        end
        if k == N
            break
        end
        % L'ultimo passo puo' essere piu' breve del periodo del controllore.
        dt = min(p.dt, p.maxTime - t(k));
        % Il confronto comprende il margine numerico. Se la distanza iniziale
        % è insufficiente, il passo si interrompe prima dell’integrazione.
        if clearance(k) <= abs(v) * dt + p.num.clearance
            error('robotica:Collisione', 'Margine insufficiente per certificare il passo %d.', k);
        end
        q = passo_ode45(q, u, dt, p, opzioni);
    end
    if ~finito
        error('robotica:Timeout', 'Goal non raggiunto entro %.1f s.', p.maxTime);
    end
    Q = Q(1:k, :);
    t = t(1:k);
    err = errore_percorso(Q(:, 1:2), wp);
    out = struct('t', t, 'q', Q, 'ruote', U(1:k, :), 'vw', vw(1:k, :), 'rho', rho(1:k), ...
               'alpha', alpha(1:k), 'modo', mode(1:k), 'waypoint', idx(1:k), ...
               'clearance', clearance(1:k), 'errore', err, 'plan', plan, 'p', p);
    out.metriche = struct('tempo', t(end), ...
                        'errore_posizione_finale', norm(Q(end, 1:2) - p.qgoal(1:2).'), ...
                        'errore_angolo_finale', abs(angolo_pi(Q(end, 3) - p.qgoal(3))), ...
                        'errore_tracking_RMS', sqrt(mean(err.^2)), ...
                        'errore_tracking_max', max(err), ...
                        'clearance_min', min(clearance(1:k)), ...
                        'picco_ruote', max(max(abs(U(1:k, :)))), ...
                        'lunghezza_eseguita', sum(sqrt(sum(diff(Q(:, 1:2)).^2, 2))), ...
                        'lunghezza_pianificata', sum(sqrt(sum(diff(wp(:, 1:2)).^2, 2))));
end
