function clearance = distanza_libera(xy, p, margine, fine)
    % DISTANZA_LIBERA Distanza firmata minima del corpo da cerchi e bordi [m].
    % Con un solo punto valuta la posa; con fine valuta l'intero segmento.
    if nargin < 3
        margine = 0;
    end
    if nargin < 4
        fine = xy;
    end
    a = xy(1:2); a = a(:);
    b = fine(1:2); b = b(:);
    d = b - a;
    lunghezza2 = dot(d, d);
    % Il centro deve restare ad almeno R dal bordo geometrico. Con margine
    % zero il risultato misura il varco fisico tra il corpo e l’ostacolo.
    R = p.robotRadius + margine;
    lim = p.bounds;
    % Ogni distanza da un lato del rettangolo e' affine lungo il segmento.
    clearance = min([min(a(1), b(1)) - lim(1), lim(2) - max(a(1), b(1)), ...
                     min(a(2), b(2)) - lim(3), lim(4) - max(a(2), b(2))]) - R;
    for i = 1:size(p.obstacles, 1)
        centro = p.obstacles(i, 1:2).';
        t = 0;
        if lunghezza2 > 0
            % t è la proiezione del centro del cerchio lungo il segmento.
            % Limitandola a [0,1] si include l’estremo più vicino, se necessario.
            t = max(0, min(1, dot(centro - a, d) / lunghezza2));
        end
        vicino = a + t * d; % Per un segmento nullo coincide con il punto a.
        dist = hypot(vicino(1) - centro(1), vicino(2) - centro(2));
        clearance = min(clearance, dist - p.obstacles(i, 3) - R);
    end
    % Una tangenza può produrre un residuo di arrotondamento positivo.
    % eps(scala) è la distanza tra numeri rappresentabili alla scala usata.
    % I residui entro quattro di questi intervalli vengono trattati come zero.
    scala = max([1; abs(lim(:)); abs(a); abs(b)]);
    if abs(clearance) <= 4 * eps(scala)
        clearance = 0;
    end
end
