function out = main_4R(animazione)
    % MAIN_4R Punto di ingresso: simulazione, CSV/MAT, grafici e animazione.
    % Da questa cartella: out=main_4R(); oppure main_4R(false) senza replay.
    if nargin < 1
        animazione = true;
    end
    base = fileparts(mfilename('fullpath'));
    addpath(base);
    cartella = fullfile(base, '..', 'risultati');
    if ~exist(cartella, 'dir')
        mkdir(cartella);
    end
    % Un’unica simulazione alimenta tutte le uscite. Il MAT conserva anche
    % i parametri, mentre nel CSV ogni riga corrisponde a un istante.
    out = simula_4R();
    save(fullfile(cartella, 'simulazione_4R.mat'), 'out');
    % CSV con intestazione: mantiene esplicito l'ordine delle colonne e le unita.
    fid = fopen(fullfile(cartella, 'simulazione_4R.csv'), 'w');
    assert(fid >= 0);
    fprintf(fid, ['t_s,q1_rad,q2_rad,q3_rad,q4_rad,qd1_rad,qd2_rad,qd3_rad,qd4_rad,' ...
                  'e1_rad,e2_rad,e3_rad,e4_rad,tau1_Nm,tau2_Nm,tau3_Nm,tau4_Nm,x_m,' ...
                  'y_m,xd_m,yd_m\n']);
    fclose(fid);
    dlwrite = [out.t, out.q, out.qd, out.e, out.tau, out.ee, out.target];
    dlmwrite(fullfile(cartella, 'simulazione_4R.csv'), dlwrite, '-append', 'precision', 16);
    grafici_4R(out, cartella);
    disp(out.metriche);
    if animazione
        anima_4R(out);
    end
end
