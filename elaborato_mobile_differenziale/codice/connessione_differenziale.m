function [valida, comandi, stati, costo] = connessione_differenziale(qa, qb, p)
    % CONNESSIONE_DIFFERENZIALE Planner locale: ruota, avanza, ruota.
    % Le colonne di comandi sono velocità destra, velocità sinistra [rad/s]
    % e durata [s]. stati contiene la posa iniziale e quella dopo ogni fase.
    % costo è il tempo totale dell’arco e vale Inf se l’arco è occupato.
    % Compatibilita con strutture di simulazione salvate prima dei settings.
    if ~isfield(p, 'num')
        cfg = settings_mobile();
        p.num = cfg.num;
    end
    qa = qa(:);
    qb = qb(:);
    comandi = zeros(0, 3);
    stati = qa.';
    costo = inf;
    [valida, ~] = segmento_libero(qa, qb, p, p.margin);
    if ~valida
        return
    end
    len = norm(qb(1:2) - qa(1:2));
    if len > p.num.zeroLength
        direzione = atan2(qb(2) - qa(2), qb(1) - qa(1));
    else
        direzione = qa(3);
    end
    % La prima rotazione allinea l’asse del telaio al segmento. La seconda
    % impone l’orientamento di arrivo dopo la traslazione. Gli angoli
    % sono avvolti per scegliere una rotazione di modulo al più pi.
    rot1 = angolo_pi(direzione - qa(3));
    rot2 = angolo_pi(qb(3) - direzione);
    primitive = [0 sign(rot1) * p.wPlan abs(rot1) / p.wPlan; ...
               p.vPlan 0 len / p.vPlan; 0 sign(rot2) * p.wPlan abs(rot2) / p.wPlan];
    q = qa;
    for j = 1:3
        if primitive(j, 3) <= p.num.zeroTime
            continue
        end
        [u, v, w] = ruote_da_twist(primitive(j, 1), primitive(j, 2), p);
        % scala è la frazione di velocità ottenuta. Dividere la durata per
        % scala conserva la distanza della traslazione o l’angolo della rotazione.
        scala = max(abs([v, w])) / max(abs(primitive(j, 1:2)));
        dt = primitive(j, 3) / scala;
        comandi(end + 1, :) = [u.' dt];
        q = passo_differenziale(q, u, dt, p);
        stati(end + 1, :) = q.';
    end
    assert(norm(q(1:2) - qb(1:2)) < p.num.endPosition && ...
           abs(angolo_pi(q(3) - qb(3))) < p.num.endAngle);
    costo = sum(comandi(:, 3));
end
