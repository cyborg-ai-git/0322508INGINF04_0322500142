function [M, C, G, energia, dM] = dynamics_4R(theta, dtheta, params)
    % DYNAMICS_4R Valuta M(q)*ddq + C(q,dq)*dq + G(q) = tau.
    % q e dq seguono l’ordine base-punta e sono espressi in rad e rad/s.
    % M è la matrice di inerzia [kg m^2]. C*dq raccoglie le coppie
    % centrifughe e di Coriolis [N m]. G è la coppia [N m] che equilibra la gravità a riposo.
    % energia contiene T e V in joule. dM(:,:,k) contiene la derivata di M
    % rispetto a q(k) e serve anche al controllo numerico delle derivate.
    validateattributes(theta, {'numeric'}, {'real', 'finite', 'vector', 'numel', 4});
    validateattributes(dtheta, {'numeric'}, {'real', 'finite', 'vector', 'numel', 4});
    q = theta(:);
    dq = dtheta(:);
    s = cumsum(q);
    L = params.L(:);
    M = zeros(4);
    G = zeros(4, 1);
    dM = zeros(4, 4, 4);
    V = 0;
    for i = 1:4
        % Il baricentro i vede le lunghezze complete dei link precedenti e c_i.
        a = [L(1:i - 1); params.c(i)];
        pc = [sum(a .* cos(s(1:i))); sum(a .* sin(s(1:i)))];
        % Ogni colonna di J dà la velocità del baricentro per velocità unitaria
        % del relativo giunto. H(:,:,k) è la derivata di J rispetto a q(k).
        J = zeros(2, 4);
        H = zeros(2, 4, 4);
        jw = zeros(1, 4);
        jw(1:i) = 1;
        for j = 1:i
            J(:, j) = [-sum(a(j:i) .* sin(s(j:i))); sum(a(j:i) .* cos(s(j:i)))];
            for k = 1:i
                % Restano i tratti a valle di entrambi i giunti j e k.
                h = max(j, k):i;
                H(:, j, k) = -[sum(a(h) .* cos(s(h))); sum(a(h) .* sin(s(h)))];
            end
        end
        % J trasforma dq in velocità del baricentro e jw in velocità angolare.
        % Sommando i due contributi energetici di ogni asta si costruisce M.
        M = M + params.m(i) * (J.' * J) + params.I(i) * (jw.' * jw);
        % Solo la quota y contribuisce al potenziale m*g*y. La seconda riga
        % di J dà la variazione di quota per ciascun angolo di giunto.
        G = G + params.m(i) * params.g * J(2, :).';
        V = V + params.m(i) * params.g * pc(2); % y positivo verso l'alto.
        for k = 1:4
            dM(:, :, k) = dM(:, :, k) + params.m(i) * (H(:, :, k).' * J + J.' * H(:, :, k));
        end
    end
    % La combinazione delle tre derivate di M è il simbolo di Christoffel.
    % La somma su k pesa ogni termine con la velocità del giunto k.
    C = zeros(4);
    for i = 1:4
        for j = 1:4
            for k = 1:4
                C(i, j) = C(i, j) + 0.5 * (dM(i, j, k) + dM(i, k, j) - dM(j, k, i)) * dq(k);
            end
        end
    end
    energia = struct('T', 0.5 * dq.' * M * dq, 'V', V);
end
