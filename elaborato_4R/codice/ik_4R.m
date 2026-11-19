function [theta, soluzioni, info] = ik_4R(x, y, phi, L, psi, gomito)
    % IK_4R Calcola gli angoli che portano la punta alla posa (x,y,phi).
    % x e y sono in metri, phi in radianti. Con quattro giunti e tre vincoli
    % di posa, si può scegliere psi, l’orientamento assoluto della terza asta.
    % theta = ik_4R(x,y,phi,L) sceglie psi e restituisce il ramo positivo.
    % [theta,S,info] = ik_4R(x,y,phi,L,psi,-1) seleziona il ramo negativo.
    % S contiene i due rami in colonna. info riporta psi e i punti intermedi.
    validateattributes(x, {'numeric'}, {'real', 'finite', 'scalar'});
    validateattributes(y, {'numeric'}, {'real', 'finite', 'scalar'});
    validateattributes(phi, {'numeric'}, {'real', 'finite', 'scalar'});
    validateattributes(L, {'numeric'}, {'real', 'finite', 'positive', 'vector', 'numel', 4});
    L = L(:);
    cfg = settings_4R();
    tol = cfg.ikTol * max(1, sum(L));
    if nargin < 5
        psi = [];
    end
    if nargin < 6
        gomito = 1;
    end
    assert(isscalar(gomito) && any(gomito == [-1 1]), 'gomito deve essere +1 o -1.');
    % Polso a monte del quarto link: rimane il problema posizionale del 3R.
    w = [x - L(4) * cos(phi); y - L(4) * sin(phi)];
    rw = norm(w);
    rmin = abs(L(1) - L(2));
    rmax = L(1) + L(2);
    if isempty(psi)
        % Il secondo polso deve appartenere alla corona raggiungibile dal 2R.
        % La sua distanza varia fra |rw-L3| e rw+L3: si intersecano gli intervalli.
        lo = max(rmin, abs(rw - L(3)));
        hi = min(rmax, rw + L(3));
        if lo > hi + tol
            error('robotica:IKNonRaggiungibile', 'La posa richiesta non e'' raggiungibile.');
        end
        if rw <= tol
            % Qui ogni direzione del link 3 e' equivalente per la raggiungibilita.
            psi = 0;
        else
            % Scelto un raggio ammissibile, il triangolo base-polso-u determina
            % l’angolo tra w e la terza asta con il teorema del coseno.
            distanza = (lo + hi) / 2;
            cdelta = (rw^2 + L(3)^2 - distanza^2) / (2 * rw * L(3));
            psi = atan2(w(2), w(1)) + acos(max(-1, min(1, cdelta)));
        end
    else
        validateattributes(psi, {'numeric'}, {'real', 'finite', 'scalar'});
    end
    u = w - L(3) * [cos(psi); sin(psi)];
    % D è cos(q2). Il segno di sin(q2) distingue le due configurazioni
    % del gomito che portano le prime due aste allo stesso punto u.
    D = (u.' * u - L(1)^2 - L(2)^2) / (2 * L(1) * L(2));
    if norm(u) < rmin - tol || norm(u) > rmax + tol
        error('robotica:IKPsiNonAmmissibile', 'Nessuna soluzione per il psi assegnato.');
    end
    D = max(-1, min(1, D));
    soluzioni = zeros(4, 2);
    for b = 1:2
        segno = 3 - 2 * b;
        q2 = atan2(segno * sqrt(max(0, 1 - D^2)), D);
        if norm(u) <= tol && abs(L(1) - L(2)) <= tol
            % 2R ripiegato con link uguali: q1 e' libero, si sceglie zero.
            q1 = 0;
        else
            q1 = atan2(u(2), u(1)) - atan2(L(2) * sin(q2), L(1) + L(2) * cos(q2));
        end
        % q3 chiude l’orientamento psi della terza asta e q4 completa phi.
        soluzioni(:, b) = [q1; q2; psi - q1 - q2; phi - psi];
    end
    theta = soluzioni(:, 1 + (gomito < 0));
    info = struct('psi', psi, 'polso', w, 'secondo_polso', u, 'cos_theta2', D, ...
                  'singolare_2R', abs(1 - abs(D)) < cfg.singularTol);
end
