function esito = verifica_4R()
    % VERIFICA_4R Test numerici indipendenti di cinematica, energia e simulazione.
    % Non basta cancellare C,G nel controllore: si verificano prima le identita
    % fisiche con differenze finite e il modello rispetto all'energia diretta.
    rng(2025, 'twister');
    p = settings_4R();
    h = 1e-6;
    maxFK = 0;
    maxIK = 0;
    maxG = 0;
    maxSkew = 0;
    minEig = inf;
    % Regressione sulle dimensioni di riferimento e derivata al primo passo ode45.
    [qr, dqr, ddqr] = riferimento_4R(0, p);
    assert(isequal(size(qr), [4 1]) && isequal(size(dqr), [4 1]) && isequal(size(ddqr), [4 1]));
    z0 = [qr + p.offset; dqr];
    dz0 = modello_4R(0, z0, p);
    assert(isequal(size(dz0), [8 1]) && isequal(dz0, modello_4R(0, z0.', p)));
    % Anche i parametri importati come righe devono produrre vettori colonna.
    righe = p;
    for campo = {'L', 'freq', 'phase', 'amp', 'qbar', 'offset'}
        nome = campo{1};
        righe.(nome) = p.(nome).';
    end
    assert(isequal(dz0, modello_4R(0, z0.', righe)));
    [M0, C0, G0] = dynamics_4R(z0(1:4), dqr, p);
    tau0 = controllo_4R(0, z0(1:4), dqr, p, M0, C0, G0);
    assert(isequal(tau0, controllo_4R(0, z0(1:4).', dqr.', righe, M0, C0, G0)));
    for durata = [0.055, 0.01]
        righe.tf = durata;
        breve = simula_4R(righe);
        assert(breve.t(end) == durata && isnan(breve.metriche.errore_dopo_2s));
        assert(numel(breve.t) == ceil(durata / righe.dt) + 1);
    end
    for n = 1:100
        q = 2 * pi * rand(4, 1) - pi;
        dq = randn(4, 1);
        [T, x, y, phi] = fk_4R(q, p.L);
        s = cumsum(q);
        maxFK = max(maxFK, norm([x; y] - [sum(p.L .* cos(s)); sum(p.L .* sin(s))]));
        assert(norm(T(1:3, 1:3).' * T(1:3, 1:3) - eye(3), 'fro') < 1e-12);
        [~, S] = ik_4R(x, y, phi, p.L);
        for b = 1:2
            [~, xi, yi, fi] = fk_4R(S(:, b), p.L);
            maxIK = max(maxIK, norm([xi - x; yi - y; atan2(sin(fi - phi), cos(fi - phi))]));
        end
        [M, C, G, en, dM] = dynamics_4R(q, dq, p);
        assert(norm(M - M.', 'fro') < 1e-12);
        minEig = min(minEig, min(eig(M)));
        gn = zeros(4, 1);
        Mdot = zeros(4);
        for j = 1:4
            delta = zeros(4, 1);
            delta(j) = h;
            [Mp, ~, ~, ep] = dynamics_4R(q + delta, dq, p);
            [Mm, ~, ~, em] = dynamics_4R(q - delta, dq, p);
            gn(j) = (ep.V - em.V) / (2 * h);
            assert(norm((Mp - Mm) / (2 * h) - dM(:, :, j), 'fro') < 1e-7);
            Mdot = Mdot + (Mp - Mm) / (2 * h) * dq(j);
        end
        maxG = max(maxG, norm(G - gn));
        % Per la matrice C di Christoffel, Mdot-2*C è antisimmetrica.
        % La somma con la sua trasposta misura il residuo di questa identità.
        Sphys = Mdot - 2 * C;
        maxSkew = max(maxSkew, norm(Sphys + Sphys.', 'fro'));
        % Energia cinetica indipendente usando velocita dei baricentri per FD.
        kinetic = 0;
        for i = 1:4
            a = [p.L(1:i - 1); p.c(i)];
            sp = cumsum(q + h * dq);
            sm = cumsum(q - h * dq);
            vp = ([sum(a .* cos(sp(1:i))); sum(a .* sin(sp(1:i)))] - ...
                [sum(a .* cos(sm(1:i))); sum(a .* sin(sm(1:i)))]) / (2 * h);
            kinetic = kinetic + 0.5 * p.m(i) * (vp.' * vp) + 0.5 * p.I(i) * sum(dq(1:i))^2;
        end
        assert(abs(kinetic - en.T) < 1e-7);
    end
    assert(maxFK < 1e-12 && maxIK < 1e-8 && minEig > 0 && maxG < 1e-7 && maxSkew < 1e-7);
    % Casi limite: estensione, polso nullo, 2R ripiegato, posa irraggiungibile.
    [~, S] = ik_4R(sum(p.L), 0, 0, p.L);
    assert(all(isfinite(S(:))));
    [~, S] = ik_4R(p.L(4), 0, 0, p.L);
    assert(all(isfinite(S(:))));
    [qa, ~, ~] = ik_4R(1.2, 0, 0, [1; 1; 1; 0.2], 0);
    [~, xx, yy] = fk_4R(qa, [1; 1; 1; 0.2]);
    assert(norm([xx - 1.2; yy]) < 1e-8);
    fallito = false;
    try
        ik_4R(20, 20, 0, p.L);
    catch err
        fallito = strcmp(err.identifier, 'robotica:IKNonRaggiungibile');
    end
    assert(fallito);
    % Confronto della dinamica chiusa con la soluzione analitica criticamente smorzata.
    out = simula_4R(p);
    e0 = -p.offset.';
    teorico = (1 + 8 * out.t) .* exp(-8 * out.t) * e0;
    assert(max(abs(out.e(:) - teorico(:))) < 2e-7);
    assert(out.metriche.errore_dopo_2s < 1e-5 && out.metriche.errore_finale < 1e-7);
    esito = struct('casi_casuali', 100, 'errore_FK', maxFK, 'errore_IK', maxIK, ...
                 'errore_gradiente_G', maxG, 'residuo_antisimmetria', maxSkew, 'min_autovalore_M', minEig, ...
                 'errore_finale', out.metriche.errore_finale, 'stato', 'SUPERATO');
    disp(esito);
end
