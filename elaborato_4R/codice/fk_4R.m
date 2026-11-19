function [T, x, y, phi] = fk_4R(theta, L)
    % FK_4R Cinematica diretta tramite Denavit-Hartenberg STANDARD.
    % theta, L: quattro angoli [rad] e quattro lunghezze positive [m].
    % T: posa 4x4 della terna 4 rispetto alla base; phi non viene avvolto.
    validateattributes(theta, {'numeric'}, {'real', 'finite', 'vector', 'numel', 4});
    validateattributes(L, {'numeric'}, {'real', 'finite', 'positive', 'vector', 'numel', 4});
    theta = theta(:);
    L = L(:);
    % La base è la terna 0. Dopo ogni prodotto, T esprime la posa della
    % terna i rispetto alla base. La traslazione è lungo l’asse x locale.
    T = eye(4);
    for i = 1:4
        % A_i=Rz(theta_i)*Tz(0)*Tx(L_i)*Rx(0): tutti gli assi z sono paralleli.
        co = cos(theta(i));
        si = sin(theta(i));
        A = [co -si 0 L(i) * co; si co 0 L(i) * si; 0 0 1 0; 0 0 0 1];
        T = T * A;
    end
    x = T(1, 4);
    y = T(2, 4);
    % La somma conserva anche i giri completi, utili per confrontare angoli
    % articolari. La sola matrice di rotazione identifica phi modulo 2*pi.
    phi = sum(theta);
end
