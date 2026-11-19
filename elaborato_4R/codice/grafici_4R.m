function grafici_4R(out, cartella)
    % GRAFICI_4R Salva grafici leggibili con unita e legende, senza toolbox.
    cfg = settings_4R();
    if ~exist(cartella, 'dir')
        mkdir(cartella);
    end
    % Le quattro colonne di q, e e tau seguono l’ordine dalla base alla punta.
    % I grafici usano gli stessi tempi per confrontare posa, errore e coppia.
    t = out.t;
    lab = {'1', '2', '3', '4'};
    f = figure('Name', 'Posizioni articolari', 'Color', 'w');
    % Impone uno sfondo da stampa senza modificare le preferenze di MATLAB.
    if isprop(f, 'Theme')
        set(f, 'Theme', 'light');
    end
    set(f, 'Position', cfg.plot.window);
    for j = 1:4
        subplot(2, 2, j);
        plot(t, out.q(:, j), 'b', t, out.qd(:, j), 'r--', 'LineWidth', 1.2);
        grid on;
        xlabel('t [s]');
        ylabel(['q_' lab{j} ' [rad]']);
        legend('Eseguita', 'Desiderata');
    end
    print(f, fullfile(cartella, 'posizioni_4R.png'), '-dpng', cfg.plot.resolution);
    f = figure('Name', 'Errori e coppie', 'Color', 'w');
    % Impone uno sfondo da stampa senza modificare le preferenze di MATLAB.
    if isprop(f, 'Theme')
        set(f, 'Theme', 'light');
    end
    set(f, 'Position', cfg.plot.window);
    subplot(2, 1, 1);
    plot(t, out.e, 'LineWidth', 1.2);
    grid on;
    xlabel('t [s]');
    ylabel('e [rad]');
    legend('e_1', 'e_2', 'e_3', 'e_4');
    subplot(2, 1, 2);
    plot(t, out.tau, 'LineWidth', 1.2);
    grid on;
    xlabel('t [s]');
    ylabel('Coppia [N m]');
    legend('tau_1', 'tau_2', 'tau_3', 'tau_4');
    print(f, fullfile(cartella, 'errori_coppie_4R.png'), '-dpng', cfg.plot.resolution);
    f = figure('Name', 'Traiettoria e terne DH', 'Color', 'w');
    % Impone uno sfondo da stampa senza modificare le preferenze di MATLAB.
    if isprop(f, 'Theme')
        set(f, 'Theme', 'light');
    end
    set(f, 'Position', cfg.plot.window);
    hold on;
    punta = plot(out.ee(:,1), out.ee(:,2), '-', 'Color', [.04 .29 .57], 'LineWidth', 2.8);
    rif = plot(out.target(:,1), out.target(:,2), '--', 'Color', [.80 .34 .10], 'LineWidth', 1.2);
    [xGiunti, yGiunti] = disegna_4R(out.q(1,:).', out.p.L);
    title('Configurazione iniziale e traiettoria della punta');
    legend([punta rif], {'Eseguita','Riferimento'}, 'Location','northwest');
    % Include base, traiettorie e frecce delle terne, evitando ritagli ai bordi.
    xx = [xGiunti; out.ee(:, 1); out.target(:, 1)];
    yy = [yGiunti; out.ee(:, 2); out.target(:, 2)];
    xlim([min(xx) - cfg.plot.staticMargin, max(xx) + cfg.plot.staticMargin]);
    ylim([min(yy) - cfg.plot.staticMargin, max(yy) + cfg.plot.staticMargin]);
    print(f, fullfile(cartella, 'traiettoria_4R.png'), '-dpng', cfg.plot.resolution);
end
