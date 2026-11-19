function esito = verifica_mobile()
    % VERIFICA_MOBILE Controlla cinematica, archi, collisioni continue e goal.
    p = settings_mobile();
    rng(18, 'twister');
    % Per una singola coppia di velocità costanti esiste un flusso esatto.
    % Confrontarlo con ode45 mette alla prova segni, carreggiata e ordine
    % delle ruote prima di verificare un percorso completo.
    maxODE = 0;
    maxVincolo = 0;
    for k = 1:100
        q = randn(3, 1);
        u = 8 * (2 * rand(2, 1) - 1);
        a = passo_ode45(q, u, p.dt, p);
        b = passo_differenziale(q, u, p.dt, p);
        maxODE = max(maxODE, norm(a - b));
        dq = modello_differenziale(0, q, u, p);
        maxVincolo = max(maxVincolo, abs([-sin(q(3)) cos(q(3))] * dq(1:2)));
        v = p.r * sum(u) / 2;
        w = p.r * (u(1) - u(2)) / p.d;
        [ur, ~, ~] = ruote_da_twist(v, w, p);
        assert(norm(ur - u) < 1e-12);
    end
    % Una posa riga e una posa colonna rappresentano lo stesso stato fisico.
    assert(isequal(a, passo_ode45(q.', u.', p.dt, p)));
    s = [1; 1; 0];
    g = [1; 1; 0.2];
    bersaglio = [2; 1.5; 0.3];
    atteso = controllo_mobile(s, bersaglio, p, false);
    assert(isequal(atteso, controllo_mobile(s.', bersaglio, p, false)));
    assert(isequal(atteso, controllo_mobile(s, bersaglio.', p, false)));
    % Un ultimo intervallo frazionario deve rispettare esattamente il timeout.
    breve = p;
    breve.q0 = s;
    breve.qgoal = g;
    breve.maxTime = 0.011;
    breve.angleTol = 0.195;
    arco = struct('waypoints', [s.'; g.']);
    risultato = simula_mobile(arco, breve);
    assert(isequal(risultato.t, [0; breve.maxTime]));
    breve.angleTol = 0.19;
    scaduto = false;
    try
        simula_mobile(arco, breve);
    catch err
        scaduto = strcmp(err.identifier, 'robotica:Timeout');
    end
    assert(scaduto);
    assert(maxODE < 1e-8 && maxVincolo < 1e-12);
    % Ruote uguali: rettilineo. Ruote opposte: rotazione sul posto.
    a = passo_differenziale([0; 0; 0], [2; 2], 1, p);
    assert(norm(a - [.14; 0; 0]) < 1e-12);
    a = passo_differenziale([1; 2; 0], [2; -2], 1, p);
    assert(norm(a(1:2) - [1; 2]) < 1e-12);
    [u, ~, ~] = ruote_da_twist(10, 20, p);
    assert(max(abs(u)) <= p.wheelMax + 1e-12);
    % Segmento con estremi liberi ma ostacolo in mezzo deve essere rifiutato.
    [ok, ~] = segmento_libero([1; 2.5], [4.2; 2.5], p, 0);
    assert(~ok);
    assert(distanza_libera([0; 4], p, 0) < 0);
    % Primo ostacolo dilatato: il segmento verticale x=4.2 e' tangente.
    % Le prove ai due lati distinguono un contatto da un varco di 1 nm.
    for scarto = [-1e-9, 0, 1e-9]
        x = 4.2 + scarto;
        [libero, minimo] = segmento_libero([x 2.35], [x; 2.65], p);
        punto = distanza_libera([x; 2.5], p, p.margin);
        assert(libero == (scarto > 0) && sign(minimo) == sign(scarto));
        assert(sign(punto) == sign(scarto));
    end
    % Segmento degenere e bordo superiore del rettangolo eroso.
    xy = [8, p.bounds(4) - p.robotRadius - p.margin];
    [libero, minimo] = segmento_libero(xy, xy, p);
    assert(~libero && minimo == 0);
    [path, dist] = dijkstra_mobile([inf 1 inf; inf inf inf; inf inf inf], 1, 3);
    assert(isempty(path) && isinf(dist));
    plan = pianifica_prm(p);
    % Ricostruire ogni arco del cammino e verificare le pose finali.
    for k = 1:numel(plan.path) - 1
        [ok, cmd, states, ~] = connessione_differenziale(plan.waypoints(k, :).', plan.waypoints(k + 1, :).', p);
        assert(ok && max(max(abs(cmd(:, 1:2)))) <= p.wheelMax + 1e-12);
        assert(norm(states(end, 1:2) - plan.waypoints(k + 1, 1:2)) < 1e-8);
    end
    assert(norm(plan.qref(end, 1:2) - p.qgoal(1:2).') < 1e-8);
    assert(abs(angolo_pi(plan.qref(end, 3) - p.qgoal(3))) < 1e-8);
    out = simula_mobile(plan, p);
    assert(out.metriche.errore_posizione_finale <= p.posTol);
    assert(out.metriche.errore_angolo_finale <= p.angleTol);
    assert(out.metriche.picco_ruote <= p.wheelMax + 1e-12);
    assert(all(out.clearance(1:end - 1) > abs(out.vw(1:end - 1, 1)) * p.dt + 1e-8));
    % L'errore trasversale resta inferiore al margine scelto nel caso nominale.
    assert(out.metriche.errore_tracking_max < p.margin);
    esito = struct('stato', 'SUPERATO', 'casi_cinematici', 100, 'errore_ode45', maxODE, ...
                 'residuo_non_olonomo', maxVincolo, 'nodi', size(plan.nodes, 1), 'archi', plan.numEdges, ...
                 'metriche', out.metriche);
    disp(esito);
end
