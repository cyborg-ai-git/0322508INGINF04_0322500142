function grafici_mobile(out, cartella)
    % GRAFICI_MOBILE Roadmap, confronto percorsi, errori, velocita ruote e clearance.
    cfg = settings_mobile();
    if ~exist(cartella, 'dir')
        mkdir(cartella);
    end
    p = out.p;
    plan = out.plan;
    t = out.t;
    f = figure('Name', 'Roadmap differenziale', 'Color', 'w');
    % Impone uno sfondo da stampa senza modificare le preferenze di MATLAB.
    if isprop(f, 'Theme')
        set(f, 'Theme', 'light');
    end
    set(f, 'Position', cfg.plot.window);
    disegna_ambiente(p);
    % Solo gli archi con costo finito appartengono alla roadmap. Il grafico
    % li proietta sul piano, dove le rotazioni sul posto appaiono come punti.
    [i, j] = find(isfinite(plan.W));
    % Ogni arco si conclude con NaN per tenere separati i segmenti in un solo plot.
    xArchi = [plan.nodes(i, 1), plan.nodes(j, 1), nan(numel(i), 1)].';
    yArchi = [plan.nodes(i, 2), plan.nodes(j, 2), nan(numel(i), 1)].';
    plot(xArchi(:), yArchi(:), '-', 'Color', [.82 .86 .91]);
    plot(plan.nodes(:, 1), plan.nodes(:, 2), '.', 'Color', [.25 .45 .7]);
    plot(plan.waypoints(:, 1), plan.waypoints(:, 2), 'r-o', 'LineWidth', 2);
    title(sprintf('PRM: %d nodi, %d archi orientati', size(plan.nodes, 1), plan.numEdges));
    print(f, fullfile(cartella, 'roadmap_mobile.png'), '-dpng', cfg.plot.resolution);
    f = figure('Name', 'Percorso pianificato ed eseguito', 'Color', 'w');
    % Impone uno sfondo da stampa senza modificare le preferenze di MATLAB.
    if isprop(f, 'Theme')
        set(f, 'Theme', 'light');
    end
    set(f, 'Position', cfg.plot.window);
    disegna_ambiente(p);
    h2 = plot(out.q(:,1), out.q(:,2), '-', 'Color', [.04 .29 .57], 'LineWidth', 3);
    h1 = plot(plan.qref(:,1), plan.qref(:,2), '--', 'Color', [.80 .34 .10], 'LineWidth', 1.2);
    % Tre pose a scala fisica mostrano allineamento, avanzamento e arrivo.
    for k = round(linspace(1, numel(t), 3))
        corpo = disegna_mobile(gca, p);
        q = out.q(k,:);
        corpo.Matrix = makehgtform('translate',[q(1:2) 0], 'zrotate', q(3));
    end
    legend([h1 h2], {'Pianificata', 'Eseguita'}, 'Location', 'northwest');
    title('Percorso e pose del veicolo in scala');
    print(f, fullfile(cartella, 'traiettorie_mobile.png'), '-dpng', cfg.plot.resolution);
    f = figure('Name', 'Errori e ruote', 'Color', 'w');
    % Impone uno sfondo da stampa senza modificare le preferenze di MATLAB.
    if isprop(f, 'Theme')
        set(f, 'Theme', 'light');
    end
    set(f, 'Position', cfg.plot.window);
    subplot(3, 1, 1);
    plot(t, out.errore, 'b', 'LineWidth', 1.2);
    grid on;
    ylabel('e percorso [m]');
    subplot(3, 1, 2);
    plot(t, out.rho, 'Color', [.8 .3 .1]);
    grid on;
    ylabel('rho waypoint [m]');
    subplot(3, 1, 3);
    plot(t, out.ruote, 'LineWidth', 1.1);
    grid on;
    ylabel('Ruote [rad/s]');
    xlabel('t [s]');
    legend('omega_R', 'omega_L');
    print(f, fullfile(cartella, 'errori_ruote_mobile.png'), '-dpng', cfg.plot.resolution);
    f = figure('Name', 'Distanza dagli ostacoli', 'Color', 'w');
    % Impone uno sfondo da stampa senza modificare le preferenze di MATLAB.
    if isprop(f, 'Theme')
        set(f, 'Theme', 'light');
    end
    set(f, 'Position', cfg.plot.window);
    plot(t, out.clearance, 'LineWidth', 1.3);
    grid on;
    xlabel('t [s]');
    ylabel('Distanza libera del corpo [m]');
    title('Clearance da ostacoli e bordi');
    print(f, fullfile(cartella, 'clearance_mobile.png'), '-dpng', cfg.plot.resolution);
end
