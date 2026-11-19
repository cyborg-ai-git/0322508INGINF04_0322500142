function anima_mobile(out, passo, attesa, fileAVI)
    % ANIMA_MOBILE Mappa in scala e dettaglio solidale al centro del veicolo.
    % Per il video: anima_mobile(mobile, 1, 0, 'mobile.avi').
    cfg = settings_mobile(); p = out.p;
    if nargin < 2, passo = 1; end
    if nargin < 3, attesa = p.dt; end
    registra = nargin >= 4 && strlength(fileAVI) > 0;
    f = figure('Name','Robot mobile differenziale','Color','w', ...
               'WindowStyle','normal','Position',cfg.plot.videoWindow);
    if isprop(f, 'Theme'), f.Theme = 'light'; end
    layout = tiledlayout(f, 2, 3, 'Padding', 'compact', 'TileSpacing', 'compact');
    title(layout, 'Robot mobile differenziale', 'FontSize', 19);
    ax = nexttile(layout, 1, [2 2]);
    disegna_ambiente(p);
    blu = [.04 .29 .57]; arancio = [.80 .34 .10];
    traccia = plot(ax, nan, nan, '-', 'Color', blu, 'LineWidth', 2.8);
    ref = plot(ax, out.plan.qref(:,1), out.plan.qref(:,2), '--', 'Color', arancio);
    wp = out.plan.waypoints;
    bersaglio = plot(ax, nan, nan, 'd', 'Color', arancio, 'MarkerSize', 9);
    corpo = disegna_mobile(ax, p);
    legend(ax, [traccia ref bersaglio], {'Percorso','Piano PRM','Waypoint'}, ...
           'Location', 'northwest');
    tempo = title(ax, ' ');
    % Il riquadro mantiene gli assi globali e ingrandisce soltanto la scala.
    zoom = nexttile(layout, 3); hold(zoom,'on'); axis(zoom,'equal');
    r = 1.35*p.robotRadius;
    axis(zoom, [-r r -r r]); grid(zoom,'on');
    xlabel(zoom,'x relativo [m]'); ylabel(zoom,'y relativo [m]');
    dettaglio = disegna_mobile(zoom, p);
    fase = title(zoom, ' '); fasi = {'Allineamento','Avanzamento', ...
                                    'Rotazione finale','Arrivo'};
    ar = nexttile(layout, 6); plot(ar, out.t, out.ruote, 'LineWidth', 1);
    grid(ar,'on'); xlabel(ar,'Tempo [s]'); ylabel(ar,'Velocita [rad/s]');
    title(ar,'Velocita delle ruote'); legend(ar, {'Destra','Sinistra'});
    cursore = xline(ar, out.t(1), 'HandleVisibility','off');
    for pannello = [ax zoom ar]
        pannello.Toolbar.Visible = 'off';
    end
    indici = unique([1:passo:numel(out.t), numel(out.t)]);
    if registra
        % La frequenza del video e la velocita di riproduzione sono indipendenti da dt.
        tv = out.t(1):cfg.plot.videoSpeed/cfg.plot.fps:out.t(end);
        if tv(end) < out.t(end), tv(end+1) = out.t(end); end
        indici = interp1(out.t, 1:numel(out.t), tv, 'nearest');
        writer = VideoWriter(fileAVI, 'Motion JPEG AVI');
        writer.FrameRate = cfg.plot.fps; open(writer);
        chiusura = onCleanup(@() close(writer)); %#ok<NASGU>
    end
    for k = indici
        if ~isgraphics(f), return; end
        q = out.q(k,:); rot = makehgtform('zrotate', q(3));
        corpo.Matrix = makehgtform('translate', [q(1:2) 0])*rot;
        dettaglio.Matrix = rot;
        set(traccia, 'XData', out.q(1:k,1), 'YData', out.q(1:k,2));
        % Si sposta il bersaglio sul waypoint attivo al campione visualizzato.
        % Il cursore indica il comando delle ruote associato alla stessa posa.
        j = out.waypoint(k);
        set(bersaglio, 'XData', wp(j,1), 'YData', wp(j,2));
        tempo.String = sprintf('Mappa   |   t = %.2f s   |   WP %d/%d', ...
                               out.t(k), j, size(wp,1));
        fase.String = fasi{out.modo(k)+1}; cursore.Value = out.t(k);
        drawnow;
        if registra
            writeVideo(writer, getframe(f));
        elseif attesa > 0
            pause(attesa);
        end
    end
end
