function [X, Y, h] = disegna_4R(q, L, h)
    % DISEGNA_4R Braccio nel piano verticale. X e Y sono le cinque origini DH.
    % Ogni asta ha una terna locale. Il terzo argomento riusa la geometria.
    cfg = settings_4R();
    L = L(:);
    % phi(1) orienta la base. phi(j+1) orienta l’asta j, perché include
    % anche la rotazione del giunto posto all’inizio di quell’asta.
    phi = [0; cumsum(q(:))];
    X = [0; cumsum(L .* cos(phi(2:end)))];
    Y = [0; cumsum(L .* sin(phi(2:end)))];
    if nargin < 3
        ax = gca;
        hold(ax, 'on');
        axis(ax, 'equal');
        grid(ax, 'on');
        xlabel(ax, 'x [m]'); ylabel(ax, 'y [m]');
        ink = [0.10 0.19 0.25];
        metal = [0.20 0.41 0.48; 0.25 0.50 0.56; 0.32 0.59 0.62; 0.48 0.69 0.69];
        % Flangia fissa, quattro bielle rastremate e nervatura di ogni asta.
        patch(ax, [-.13 .13 .10 -.10], [-.13 -.13 -.05 -.05], ink);
        for vite = [-.085 .085]
            line(ax, vite, -.093, 'Marker', '.', 'Color', [.76 .82 .83]);
        end
        for j = 1:4
            h.asta(j) = hgtransform('Parent', ax);
            u = [0 .12 .85 1 .85 .12] * L(j);
            v = [-.040 -.059 -.039 0 .039 .059] * L(j)/L(1);
            patch('Parent', h.asta(j), 'XData', u, 'YData', v, ...
                  'FaceColor', metal(j,:), 'EdgeColor', ink);
            line([.18 .78]*L(j), [0 0], 'Parent', h.asta(j), ...
                 'Color', [.77 .89 .86], 'LineWidth', 1.4);
        end
        for j = 1:5
            h.terna(j) = hgtransform('Parent', ax);
            a = linspace(0, 2*pi, 33);
            r = .045 * L(1)/.8;
            patch('Parent', h.terna(j), 'XData', r*cos(a), 'YData', r*sin(a), ...
                  'FaceColor', [0.92 0.94 0.92], 'EdgeColor', ink);
            % Corona del riduttore e mozzo centrale. L'ultima corona indica la punta.
            finitura = [.36 .47 .50];
            if j == 5, finitura = [.90 .57 .18]; end
            patch('Parent', h.terna(j), 'XData', .64*r*cos(a), 'YData', .64*r*sin(a), ...
                  'FaceColor', finitura, 'EdgeColor', ink);
            % Due frecce locali. Il punto al centro indica z uscente dal piano.
            freccia(h.terna(j), 0, cfg.plot.frameScale, [.80 .18 .14]);
            freccia(h.terna(j), pi/2, cfg.plot.frameScale, [0 .48 .29]);
            line(0, 0, 'Parent', h.terna(j), 'Marker', '.', 'Color', ink);
            h.nome(j) = text(ax, 0, 0, sprintf('{%d}', j-1), ...
                             'FontSize', 9, 'Color', ink, 'Interpreter', 'none');
        end
    end
    for j = 1:5
        % L’origine è comune alla terna e all’asta che parte da quel punto.
        % La terna usa phi(j), mentre l’asta successiva ruota di un altro giunto.
        origine = makehgtform('translate', [X(j) Y(j) 0]);
        h.terna(j).Matrix = origine * makehgtform('zrotate', phi(j));
        h.nome(j).Position = [X(j)+.068, Y(j)-.046, 0];
        if j <= 4
            h.asta(j).Matrix = origine * makehgtform('zrotate', phi(j+1));
        end
    end
end

function freccia(gruppo, angolo, scala, colore)
    % Il profilo comprende asta e punta, ruotate insieme con la terna DH.
    xy = scala * [0 1 .72 1 .72; 0 0 .15 0 -.15];
    R = [cos(angolo) -sin(angolo); sin(angolo) cos(angolo)];
    xy = R * xy;
    line(xy(1,:), xy(2,:), 'Parent', gruppo, 'Color', colore, 'LineWidth', 1.15);
end
