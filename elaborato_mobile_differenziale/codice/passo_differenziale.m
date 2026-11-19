function qn = passo_differenziale(q, ruote, dt, p)
    % PASSO_DIFFERENZIALE Flusso ESATTO del modello a velocita ruote costanti.
    % Usato per le primitive PRM: nessuna traslazione laterale o interpolazione
    % diretta delle pose. La simulazione del controllore usa invece ode45.
    % Compatibilita con strutture di simulazione salvate prima dei settings.
    if ~isfield(p, 'num')
        cfg = settings_mobile();
        p.num = cfg.num;
    end
    v = p.r * (ruote(1) + ruote(2)) / 2;
    w = p.r * (ruote(1) - ruote(2)) / p.d;
    % Durante dt il telaio ruota di a radianti. Lo spostamento del centro
    % è la corda dell’arco e punta nella direzione intermedia q(3)+a/2.
    a = w * dt;
    mezzo = a / 2;
    if abs(mezzo) < p.num.smallAngle
        sinc0 = 1 - mezzo^2 / 6 + mezzo^4 / 120; % sin(u)/u stabile per u vicino a zero.
    else
        sinc0 = sin(mezzo) / mezzo;
    end
    qn = q(:) + [v * dt * sinc0 * cos(q(3) + mezzo); v * dt * sinc0 * sin(q(3) + mezzo); a];
end
