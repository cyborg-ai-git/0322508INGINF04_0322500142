function dz = modello_4R(t, z, p)
    % MODELLO_4R Stato z=[q;dq] e dinamica chiusa utilizzata da ode45.
    % La derivata ha sempre otto righe, anche per uno stato fornito come riga.
    validateattributes(z, {'numeric'}, {'real', 'finite', 'vector', 'numel', 8});
    z = z(:);
    q = z(1:4);
    dq = z(5:8);
    [M, C, G] = dynamics_4R(q, dq, p);
    tau = controllo_4R(t, q, dq, p, M, C, G);
    % Tolte dalla coppia le componenti C*dq e G, il sistema lineare dà ddq.
    % ode45 riceve otto derivate in colonna, prima le velocità e poi le accelerazioni.
    dz = [dq; M \ (tau - C * dq - G)];
end
