function verifica_simbolica_4R(modello)
    % VERIFICA_SIMBOLICA_4R Confronta le equazioni simboliche con la dinamica numerica.
    % Accetta il modello gia calcolato per evitare di ripetere le semplificazioni.
    if nargin < 1
        modello = derivazione_simbolica_4R();
    end
    assert(isequal(modello.residuo, sym(zeros(4, 1))), 'Residuo simbolico non nullo.');
    % Si sostituiscono gli stessi angoli, velocità e parametri nelle formule
    % simboliche e nella funzione numerica, poi si confrontano M, C e G.
    p = settings_4R();
    qn = [0.3; -0.8; 0.5; 0.2];
    dqn = [0.4; 0.1; -0.3; 0.2];
    vars = [modello.q; modello.dq; modello.L; modello.m; modello.c; modello.I; modello.g];
    vals = [qn; dqn; p.L; p.m; p.c; p.I; p.g];
    [Mn, Cn, Gn] = dynamics_4R(qn, dqn, p);
    Ms = double(subs(modello.M, vars, vals));
    Cs = double(subs(modello.C, vars, vals));
    Gs = double(subs(modello.G, vars, vals));
    assert(norm(Ms - Mn, 'fro') < 1e-9 && norm(Cs - Cn, 'fro') < 1e-9 && norm(Gs - Gn) < 1e-9);
end
