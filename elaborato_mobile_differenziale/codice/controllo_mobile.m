function [u, rho, alpha, modo, v, w] = controllo_mobile(q, target, p, finale)
    % CONTROLLO_MOBILE Controllore polare con allineamento e orientazione terminale.
    % rho [m] è la distanza dal waypoint, alpha [rad] è la rotazione per
    % puntarlo. modo identifica allineamento (0), avanzamento (1),
    % rotazione finale (2) e arresto (3). u contiene ruota destra e sinistra.
    q = q(:);
    target = target(:);
    delta = target(1:2) - q(1:2);
    rho = norm(delta);
    alpha = angolo_pi(atan2(delta(2), delta(1)) - q(3));
    if rho <= p.posTol
        v = 0;
        w = 0;
        modo = 3;
        % Raggiunta la posizione del goal, resta da regolare il solo angolo
        % della posa finale. Il centro del veicolo resta fermo.
        if finale
            err = angolo_pi(target(3) - q(3));
            if abs(err) > p.angleTol
                w = p.ktheta * err;
                modo = 2;
            end
        end
    elseif abs(alpha) > p.alignThreshold
        v = 0;
        w = p.kalpha * alpha;
        modo = 0;
    else
        v = p.krho * rho;
        w = p.kalpha * alpha;
        modo = 1;
    end
    % Prima si limitano v e w del telaio, poi si impone il limite sulle
    % ruote. La funzione restituisce le velocità effettive dopo entrambi.
    v = min(p.vMax, max(-p.vMax, v));
    w = min(p.wMax, max(-p.wMax, w));
    [u, v, w] = ruote_da_twist(v, w, p);
end
