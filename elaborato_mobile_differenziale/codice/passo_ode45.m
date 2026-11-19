function qn = passo_ode45(q, ruote, dt, p, opzioni)
    % PASSO_ODE45 Integra la cinematica per un solo intervallo di controllo.
    % Il controllore aggiorna le ruote soltanto al termine dell'intervallo.
    if nargin < 5
        cfg = settings_mobile();
        if isfield(p, 'ode')
            cfg.ode = p.ode;
        end
        opzioni = odeset('RelTol', cfg.ode.relTol, 'AbsTol', cfg.ode.absTol);
    end
    % Il comando ruote resta costante da 0 a dt. ode45 restituisce anche
    % i punti interni. L’ultima riga di pose inizializza il passo successivo.
    [~, pose] = ode45(@(t, z) modello_differenziale(t, z, ruote, p), ...
                      [0 dt], q(:), opzioni);
    qn = pose(end, :).';
end
