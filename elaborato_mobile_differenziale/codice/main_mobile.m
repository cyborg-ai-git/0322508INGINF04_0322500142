function out = main_mobile(animazione)
    % MAIN_MOBILE Esegue PRM, controllo differenziale, esportazione e animazione.
    % Uso dalla cartella codice: out=main_mobile(); main_mobile(false) evita replay.
    if nargin < 1
        animazione = true;
    end
    base = fileparts(mfilename('fullpath'));
    addpath(base);
    cartella = fullfile(base, '..', 'risultati');
    if ~exist(cartella, 'dir')
        mkdir(cartella);
    end
    p = settings_mobile();
    % Il PRM produce waypoint e un riferimento temporale. Il controllore
    % insegue i waypoint e salva separatamente la traiettoria eseguita.
    plan = pianifica_prm(p);
    out = simula_mobile(plan, p);
    save(fullfile(cartella, 'simulazione_mobile.mat'), 'out');
    fid = fopen(fullfile(cartella, 'simulazione_mobile.csv'), 'w');
    assert(fid >= 0);
    fprintf(fid, ['t_s,x_m,y_m,theta_rad,omega_R_rad_s,omega_L_rad_s,v_m_s,w_rad_s,' ...
                  'rho_m,alpha_rad,errore_percorso_m,clearance_m,waypoint,modo\n']);
    fclose(fid);
    dlmwrite(fullfile(cartella, 'simulazione_mobile.csv'), ...
             [out.t, out.q, out.ruote, out.vw, out.rho, out.alpha, out.errore, ...
              out.clearance, out.waypoint, out.modo], ...
             '-append', 'precision', 16);
    fid = fopen(fullfile(cartella, 'riferimento_mobile.csv'), 'w');
    assert(fid >= 0);
    fprintf(fid, 't_s,x_m,y_m,theta_rad\n');
    fclose(fid);
    dlmwrite(fullfile(cartella, 'riferimento_mobile.csv'), [plan.tref, plan.qref], ...
             '-append', 'precision', 16);
    grafici_mobile(out, cartella);
    disp(out.metriche);
    if animazione
        anima_mobile(out);
    end
end
