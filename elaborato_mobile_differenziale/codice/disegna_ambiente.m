function disegna_ambiente(p)
    % DISEGNA_AMBIENTE Cerchi reali, ingombri dilatati e limiti del rettangolo.
    hold on;
    cfg = settings_mobile();
    a = linspace(0, 2 * pi, cfg.plot.mapPoints);
    for i = 1:size(p.obstacles, 1)
        o = p.obstacles(i, :);
        % Il disco pieno rappresenta l’ostacolo reale. La circonferenza
        % tratteggiata delimita le posizioni escluse per il centro del robot.
        R = o(3) + p.robotRadius + p.margin;
        plot(o(1) + R * cos(a), o(2) + R * sin(a), '--', 'Color', [.55 .62 .63]);
        fill(o(1) + o(3) * cos(a), o(2) + o(3) * sin(a), [.31 .39 .44], 'EdgeColor', 'none');
    end
    plot(p.q0(1), p.q0(2), 'o', 'Color', [.03 .43 .30], 'MarkerFaceColor', [.68 .87 .73]);
    plot(p.qgoal(1), p.qgoal(2), 'p', 'Color', [.62 .23 .06], 'MarkerFaceColor', [1 .73 .35], 'MarkerSize', 12);
    axis equal;
    axis(p.bounds);
    grid on;
    xlabel('x [m]');
    ylabel('y [m]');
end
