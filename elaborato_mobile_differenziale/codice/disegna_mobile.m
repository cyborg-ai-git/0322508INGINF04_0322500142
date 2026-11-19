function corpo = disegna_mobile(ax, p)
    % DISEGNA_MOBILE Costruisce il robot in coordinate solidali al telaio.
    % L'asse locale x punta in avanti. I centri ruota distano esattamente d.
    % Ogni vertice è espresso rispetto al centro dell’asse delle ruote.
    % L’animazione assegna a corpo una sola traslazione e una rotazione.
    corpo = hgtransform('Parent', ax);
    r = p.robotRadius;
    bordo = [.10 .19 .25];
    a = linspace(0, 2*pi, 65);
    line(r*cos(a), r*sin(a), 'Parent', corpo, 'Color', [.42 .55 .56], ...
         'LineStyle', ':');                     % Disco di collisione.
    for lato = [-1 1]
        x = p.r * [-1 1 1 -1];
        y = lato*p.d/2 + r*[-.10 -.10 .10 .10];
        pezzo(corpo, x, y, bordo, bordo);
        for t = [-.55 0 .55]                    % Tasselli del battistrada.
            line(p.r*[t t], y([1 3]), 'Parent', corpo, 'Color', [.69 .75 .76]);
        end
    end
    x = r*[-.76 -.48 .46 .78 .78 .46 -.48 -.76];
    y = r*[-.34 -.62 -.62 -.32 .32 .62 .62 .34];
    pezzo(corpo, x, y, [.24 .53 .55], bordo);
    % Fasce sui fianchi: destra blu (y negativo), sinistra arancio.
    bande = [0 .45 .74; .85 .33 .10];
    for k = 1:2
        lato = 2*k-3;
        pezzo(corpo, r*[-.47 .43 .57 -.55], ...
              lato*r*[.57 .57 .47 .47], bande(k,:), bordo);
        for vite = [-.43 .42]
            line(r*vite, lato*r*.35, 'Parent', corpo, 'Marker', '.', 'Color', bordo);
        end
    end
    pezzo(corpo, r*[.12 .65 .12], r*[-.23 0 .23], [.99 .78 .34], bordo);
    pezzo(corpo, r*(-.28+.24*cos(a)), r*.24*sin(a), [.13 .23 .27], bordo);
    pezzo(corpo, r*(-.28+.16*cos(a)), r*.16*sin(a), [.75 .86 .85], bordo);
    line(r*[-.32 -.23], r*[.03 .03], 'Parent', corpo, 'Color', bordo);
end

function pezzo(gruppo, x, y, faccia, bordo)
    % La stessa trasformazione rigida muove scocca, sensore e ruote.
    patch('Parent', gruppo, 'XData', x, 'YData', y, ...
          'FaceColor', faccia, 'EdgeColor', bordo, 'LineWidth', .8);
end
