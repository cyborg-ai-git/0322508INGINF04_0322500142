function anima_4R(out, passo, attesa, fileAVI)
    % ANIMA_4R Riproduce i campioni o registra il moto in un AVI Motion JPEG.
    % Per il video: anima_4R(braccio, 1, 0, 'braccio.avi').
    cfg = settings_4R();
    % Importa le opzioni della prova e integra quelle dei salvataggi precedenti.
    if isfield(out.p, 'plot')
        for campo = fieldnames(out.p.plot).'
            nome = campo{1}; cfg.plot.(nome) = out.p.plot.(nome);
        end
    end
    articolato = isfield(cfg.plot, 'tracceInterne') && cfg.plot.tracceInterne;
    if nargin < 2, passo = 1; end
    if nargin < 3, attesa = out.p.dt; end
    registra = nargin >= 4 && strlength(fileAVI) > 0;
    f = figure('Name', 'Manipolatore planare 4R', 'Color', 'w', ...
               'WindowStyle', 'normal', 'Position', cfg.plot.videoWindow);
    if isprop(f, 'Theme'), f.Theme = 'light'; end
    righe = 2 + articolato;
    layout = tiledlayout(f, righe, 3, 'Padding','compact', 'TileSpacing','compact');
    titolo = 'Manipolatore planare 4R';
    if articolato, titolo = 'Manipolatore 4R a grande escursione'; end
    title(layout, titolo, 'FontSize', 19);
    ax = nexttile(layout, 1, [righe 2]);
    hold(ax, 'on');
    arancio = [.80 .34 .10]; blu = [.04 .29 .57];
    traccia = plot(ax, nan, nan, '-', 'Color', blu, 'LineWidth', 2.8);
    ref = plot(ax, out.target(:,1), out.target(:,2), '--', 'Color', arancio);
    target = plot(ax, nan, nan, 'd', 'Color', arancio, 'MarkerSize', 8);
    [~, ~, h] = disegna_4R(out.q(1,:).', out.p.L);
    % Inquadratura fissa determinata da tutte le pose, incluse base e terne.
    angoli = cumsum(out.q, 2);
    xx = cumsum(cos(angoli).*out.p.L(:).', 2);
    yy = cumsum(sin(angoli).*out.p.L(:).', 2);
    x = [0; xx(:); out.target(:,1)]; y = [0; yy(:); out.target(:,2)];
    m = cfg.plot.replayMargin;
    xlim(ax, [min(x)-m max(x)+m]); ylim(ax, [min(y)-m max(y)+m]);
    if articolato
        % La colonna j contiene l'origine DH Oj, a valle dell'asta j.
        % O0 e' la base fissa. O4 coincide con la punta gia' tracciata.
        scie = gobjects(1,3);
        colori = lines(3);
        for j = 1:3
            scie(j) = plot(ax,nan,nan,':','Color',colori(j,:), 'LineWidth',1.5);
        end
        legend(ax, [traccia ref scie], {'Punta O4','Riferimento','O1','O2','O3'}, ...
               'Location','southoutside','Orientation','horizontal');
    else
        legend(ax, [traccia ref], {'Punta', 'Riferimento'}, 'Location','northwest');
    end
    subtitle(ax, 'Terne DH   x rosso   /   y verde   /   z uscente');
    tempo = title(ax, ' ');
    % I cursori leggono out.t(k), lo stesso istante usato per la geometria.
    % Si può così associare una piega del braccio a un angolo o a una coppia.
    aq = nexttile(layout, 3); plot(aq, out.t, out.q, 'LineWidth', 1.4);
    grid(aq,'on'); title(aq,'Posizioni articolari'); ylabel(aq,'q [rad]');
    legend(aq, {'q_1','q_2','q_3','q_4'}, 'Location','best','NumColumns',2);
    cq = xline(aq, out.t(1), 'Color', [.25 .29 .32], 'HandleVisibility','off');
    ae = nexttile(layout, 6);
    pannelli = [ax aq ae];
    if articolato
        % Stesso ordine di colori per posizione, errore qd-q e coppia.
        plot(ae,out.t,out.e,'LineWidth',1.2); title(ae,'Errori articolari');
        ylabel(ae,'e [rad]');
        at = nexttile(layout,9); plot(at,out.t,out.tau,'LineWidth',1.2);
        grid(at,'on'); title(at,'Coppie ai giunti'); ylabel(at,'Coppia [N m]');
        xlabel(at,'Tempo [s]'); ct = xline(at,out.t(1));
        pannelli(end+1) = at;
    else
        plot(ae,out.t,1000*vecnorm(out.ee-out.target,2,2),'Color',blu);
        title(ae,'Errore della punta'); ylabel(ae,'Distanza [mm]'); xlabel(ae,'Tempo [s]');
    end
    grid(ae,'on'); ce = xline(ae,out.t(1));
    uistack(target, 'top');
    for pannello = pannelli
        pannello.Toolbar.Visible = 'off';
    end
    indici = unique([1:passo:numel(out.t), numel(out.t)]);
    if registra
        % Tra due fotogrammi trascorrono videoSpeed/fps secondi simulati.
        % Per ciascun istante video si mostra il campione ode45 più vicino.
        tv = out.t(1):cfg.plot.videoSpeed/cfg.plot.fps:out.t(end);
        if tv(end) < out.t(end), tv(end+1) = out.t(end); end
        indici = interp1(out.t, 1:numel(out.t), tv, 'nearest');
        writer = VideoWriter(fileAVI, 'Motion JPEG AVI');
        writer.FrameRate = cfg.plot.fps; open(writer);
        chiusura = onCleanup(@() close(writer)); %#ok<NASGU>
    end
    for k = indici
        if ~isgraphics(f), return; end
        disegna_4R(out.q(k,:).', out.p.L, h);
        set(traccia, 'XData', out.ee(1:k,1), 'YData', out.ee(1:k,2));
        set(target, 'XData', out.target(k,1), 'YData', out.target(k,2));
        tempo.String = sprintf('Piano di lavoro   |   t = %.2f s', out.t(k));
        if articolato
            inizio = find(out.t >= out.t(k)-cfg.plot.durataScia,1);
            for j = 1:3
                set(scie(j),'XData',xx(inizio:k,j),'YData',yy(inizio:k,j));
            end
            ct.Value = out.t(k);
        end
        cq.Value = out.t(k); ce.Value = out.t(k);
        drawnow;
        if registra
            writeVideo(writer, getframe(f));
        elseif attesa > 0
            pause(attesa);
        end
    end
end
