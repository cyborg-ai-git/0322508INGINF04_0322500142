function err = errore_percorso(xy, waypoints)
    % ERRORE_PERCORSO Distanza ortogonale minima dalla polilinea pianificata [m].
    % Diversa da rho (distanza dal waypoint attivo), che salta al cambio di target.
    % Per ogni posizione simulata si cerca il punto più vicino su ciascun
    % segmento. Il minimo finale è uno scostamento geometrico in metri.
    err = inf(size(xy, 1), 1);
    for j = 1:size(waypoints, 1) - 1
        a = waypoints(j, 1:2);
        d = waypoints(j + 1, 1:2) - a;
        if d * d.' < eps
            dist = sqrt(sum((xy - a).^2, 2));
        else
            % s=0 e s=1 individuano gli estremi. Un valore intermedio identifica
            % il piede della perpendicolare sul segmento.
            s = max(0, min(1, ((xy - a) * d.') / (d * d.')));
            dist = sqrt(sum((xy - (a + s * d)).^2, 2));
        end
        err = min(err, dist);
    end
end
