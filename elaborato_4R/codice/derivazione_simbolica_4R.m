function modello = derivazione_simbolica_4R(cartella)
    % DERIVAZIONE_SIMBOLICA_4R Ricava M,C,G dalle energie con algebra simbolica.
    % La derivazione richiede MATLAB con Symbolic Math Toolbox.
    % La simulazione numerica non richiede toolbox. Il risultato contiene anche
    % il residuo di Eulero-Lagrange, che deve risultare identicamente nullo.
    if nargin < 1
        cartella = fullfile(fileparts(mfilename('fullpath')), '..', 'risultati');
    end
    if ~exist(cartella, 'dir')
        mkdir(cartella);
    end
    syms q1 q2 q3 q4 dq1 dq2 dq3 dq4 ddq1 ddq2 ddq3 ddq4 real;
    syms L1 L2 L3 L4 m1 m2 m3 m4 c1 c2 c3 c4 I1 I2 I3 I4 g positive;
    q = [q1; q2; q3; q4];
    dq = [dq1; dq2; dq3; dq4];
    ddq = [ddq1; ddq2; ddq3; ddq4];
    L = [L1; L2; L3; L4];
    m = [m1; m2; m3; m4];
    c = [c1; c2; c3; c4];
    I = [I1; I2; I3; I4];
    s = cumsum(q);
    T = sym(0);
    V = sym(0);
    for i = 1:4
        pc = sym(zeros(2, 1));
        for k = 1:i
            if k == i
                a = c(i);
            else
                a = L(k);
            end
            pc = pc + a * [cos(s(k)); sin(s(k))];
        end
        % La derivata di pc rispetto ai quattro angoli dà il Jacobiano lineare.
        % Le velocità dei giunti a monte si sommano attorno allo stesso asse z.
        J = jacobian(pc, q);
        vc = J * dq;
        wi = sum(dq(1:i));
        T = T + (m(i) * (vc.' * vc) + I(i) * wi^2) / 2;
        V = V + m(i) * g * pc(2);
    end
    % T è quadratica in dq. Derivandola due volte rispetto alle velocità
    % si isola M. Il gradiente di V rispetto agli angoli restituisce G.
    M = simplify(jacobian(jacobian(T, dq).', dq));
    G = simplify(jacobian(V, q).');
    C = sym(zeros(4));
    for i = 1:4
        for j = 1:4
            for k = 1:4
                christoffel = (diff(M(i, j), q(k)) + diff(M(i, k), q(j)) ...
                               - diff(M(j, k), q(i))) / 2;
                C(i, j) = C(i, j) + christoffel * dq(k);
            end
        end
    end
    C = simplify(C);
    lag = T - V;
    % Il momento generalizzato dipende da q e dq. La sua derivata nel tempo
    % somma il contributo delle velocità e quello delle accelerazioni.
    % EL viene confrontato con M*ddq+C*dq+G per ciascuno dei quattro giunti.
    EL = jacobian(jacobian(lag, dq).', q) * dq + ...
       jacobian(jacobian(lag, dq).', dq) * ddq - jacobian(lag, q).';
    residuo = simplify(EL - M * ddq - C * dq - G);
    modello = struct('q', q, 'dq', dq, 'L', L, 'm', m, 'c', c, 'I', I, 'g', g, ...
                   'T', T, 'V', V, 'M', M, 'C', C, 'G', G, 'residuo', residuo);
    % Il MAT conserva gli oggetti simbolici; il TXT e' leggibile senza toolbox.
    save(fullfile(cartella, 'modello_simbolico_4R.mat'), 'modello');
    fid = fopen(fullfile(cartella, 'derivazione_simbolica_4R.txt'), 'w');
    assert(fid >= 0);
    cleanup = onCleanup(@() fclose(fid));
    nomi = {'T', 'V', 'M', 'C', 'G', 'residuo'};
    for k = 1:numel(nomi)
        fprintf(fid, '\n%s =\n%s\n', nomi{k}, char(modello.(nomi{k})));
    end
end
