function plan = pianifica_prm(p)
    % PIANIFICA_PRM Roadmap probabilistica di pose [x y theta] con archi differenziali.
    % I nodi 1 e 2 sono partenza e arrivo. Un campione entra nella roadmap
    % se il disco del robot, con il margine richiesto, è libero in quella posa.
    assert(distanza_libera(p.q0, p, p.margin) > 0, 'Start non valido.');
    assert(distanza_libera(p.qgoal, p, p.margin) > 0, 'Goal non valido.');
    rng(p.seed, 'twister');
    nodes = [p.q0.'; p.qgoal.'];
    tentativi = 0;
    b = p.bounds;
    while size(nodes, 1) < p.nSamples + 2 && tentativi < p.maxSampleAttempts
        tentativi = tentativi + 1;
        q = [b(1) + (b(2) - b(1)) * rand; b(3) + (b(4) - b(3)) * rand; 2 * pi * rand - pi];
        if distanza_libera(q, p, p.margin) > 0
            nodes(end + 1, :) = q.';
        end
    end
    if size(nodes, 1) < p.nSamples + 2
        error('robotica:CampioniInsufficienti', 'Limite tentativi di campionamento raggiunto.');
    end
    N = size(nodes, 1);
    % W(i,j) contiene la durata del collegamento i -> j. Inf indica un arco
    % assente. edges conserva i comandi necessari per ripercorrere l’arco.
    W = inf(N);
    edges = cell(N);
    for i = 1:N
        % La distanza in x,y seleziona i candidati. L’orientamento incide
        % sulla durata delle rotazioni calcolate dal pianificatore locale.
        ds = sqrt(sum((nodes(:, 1:2) - nodes(i, 1:2)).^2, 2));
        ds(i) = inf;
        [~, ind] = sort(ds);
        ind = ind(1:min(p.neighbors, N - 1));
        for j = ind.'
            if ds(j) > p.connectionRadius
                continue
            end
            [ok, cmd, ~, cost] = connessione_differenziale(nodes(i, :).', nodes(j, :).', p);
            if ok
                W(i, j) = cost;
                edges{i, j} = cmd;
            end
        end
    end
    [path, costo] = dijkstra_mobile(W, 1, 2);
    if isempty(path)
        error('robotica:PRMDisconnesso', ...
              'Nessun percorso nella roadmap; aumentare campioni o vicini.');
    end
    % Il percorso di Dijkstra contiene indici di nodi. Le righe di cmd
    % ricostruiscono, nell’ordine, velocità delle due ruote e durata.
    cmd = zeros(0, 3);
    for k = 1:numel(path) - 1
        cmd = [cmd; edges{path(k), path(k + 1)}];
    end
    % Ogni primitiva è suddivisa in intervalli di durata al più referenceStep.
    % Il flusso a ruote costanti produce pose e tempi anche nelle rotazioni
    % sul posto, durante le quali cambiano il tempo e l’angolo del telaio.
    Q = p.q0.';
    tempi = 0;
    q = p.q0;
    tempo = 0;
    for i = 1:size(cmd, 1)
        n = max(1, ceil(cmd(i, 3) / p.referenceStep));
        dt = cmd(i, 3) / n;
        for j = 1:n
            q = passo_differenziale(q, cmd(i, 1:2).', dt, p);
            tempo = tempo + dt;
            Q(end + 1, :) = q.';
            tempi(end + 1, 1) = tempo;
        end
    end
    plan = struct('nodes', nodes, 'W', W, 'path', path, 'waypoints', nodes(path, :), ...
                'commands', cmd, 'qref', Q, 'tref', tempi, 'cost', costo, 'attempts', tentativi, ...
                'numEdges', sum(isfinite(W(:))));
end
