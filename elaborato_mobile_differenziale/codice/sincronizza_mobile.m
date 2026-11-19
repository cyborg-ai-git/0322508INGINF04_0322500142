function codice = sincronizza_mobile(cartellaBase)
    % SINCRONIZZA_MOBILE Clona o aggiorna il progetto pubblico da MATLAB Online.
    % Senza argomenti usa MATLAB Drive. Una cartella base alternativa consente
    % di mantenere un secondo clone. La funzione restituisce il percorso attivo.
    if nargin < 1
        cartellaBase = matlabdrive;
    end

    % Git viene eseguito nella cartella scelta. I comandi contengono solo il
    % nome e l'URL fissati qui. All'uscita si ripristina la cartella originale.
    precedente = pwd;
    ripristina = onCleanup(@() cd(precedente));
    cd(cartellaBase);
    nome = '0322508INGINF04_0322500142';
    url = ['https://github.com/cyborg-ai-git/' nome '.git'];
    radice = fullfile(pwd, nome);
    if ~isfolder(fullfile(radice, '.git'))
        % Con --depth 1 il primo clone scarica l’ultima revisione di main.
        % I filmati si possono scaricare a parte dalla release.
        eseguiGit(['git clone --depth 1 --branch main ' url ' ' nome]);
    else
        cd(radice);
        origine = eseguiGit('git remote get-url origin');
        assert(strcmp(origine, url) || strcmp(origine, erase(url, '.git')), ...
               'La destinazione contiene un altro repository.');
        ramo = eseguiGit('git branch --show-current');
        assert(strcmp(ramo, 'main'), 'Selezionare il ramo main prima del pull.');
        modifiche = eseguiGit('git status --porcelain --untracked-files=no');
        assert(isempty(modifiche), 'Salvare le modifiche locali prima del pull.');
        % Fast-forward: eventuali commit divergenti restano disponibili.
        eseguiGit('git pull --ff-only origin main');
    end

    codice = fullfile(radice, 'elaborato_mobile_differenziale', 'codice');
    assert(isfile(fullfile(codice, 'main_mobile.m')), 'Sorgente principale assente.');
    % La precedenza nel path fa sì che MATLAB usi i file di questo clone
    % anche se un’altra copia di main_mobile è già presente nel path.
    addpath(codice, '-begin');
    rehash;
    fprintf('Pronto: %s\n', codice);
end

function testo = eseguiGit(comando)
    % Restituisce l'output del client Git e propaga il diagnostico se fallisce.
    [stato, testo] = system(comando);
    testo = strtrim(testo);
    if stato ~= 0
        error('robotica:Git', '%s', testo);
    end
end
