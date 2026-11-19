# Elaborati di robotica in MATLAB

I due progetti si eseguono in **MATLAB** o **MATLAB Online**. Entrambi usano MATLAB di base per simulazione, grafici e animazioni. La derivazione simbolica del manipolatore richiede **Symbolic Math Toolbox**.

| Progetto | Modello | Risultati |
| --- | --- | --- |
| [Manipolatore planare 4R](elaborato_4R/codice) | Cinematica DH e inversa analitica a due rami, dinamica di Eulero–Lagrange e controllo a coppia calcolata con integrazione `ode45` | Posizioni articolari, errori, coppie e traiettoria dell’organo terminale |
| [Robot mobile differenziale](elaborato_mobile_differenziale/codice) | Pianificazione PRM con primitive delle due ruote, ricerca di Dijkstra, controllo polare a waypoint e integrazione campionata con `ode45` | Roadmap, percorsi pianificato ed eseguito, scostamento dal percorso, velocità delle ruote e distanza dagli ostacoli |

## Video delle simulazioni

Puoi guardare le tre simulazioni qui sotto o scaricare i singoli MP4 dalla [release delle simulazioni](https://github.com/cyborg-ai-git/0322508INGINF04_0322500142/releases/tag/simulazioni-ode45-v2).

### Manipolatore 4R a grande escursione

https://github.com/user-attachments/assets/f4cd2d8d-4c20-4cb5-a444-235f4e14313b

In 12 s la catena si piega e si distende sui due lati della base. Le scie puntinate seguono le origini interne O1, O2 e O3. La punta O4 lascia la traccia blu. A destra, i cursori sincronizzano posizione, errore e coppia dei quattro giunti. Il video include tutti i 601 campioni MATLAB a 50 fotogrammi/s. [Scarica il video MP4](https://github.com/cyborg-ai-git/0322508INGINF04_0322500142/releases/download/simulazioni-ode45-v2/manipolatore_4R_articolato.mp4)

### Manipolatore 4R nella prova nominale

https://github.com/user-attachments/assets/54d0e393-5f7a-4951-ac9f-3164bd291c95

Dieci secondi a velocità reale. Le terne DH seguono i quattro giunti durante l’inseguimento del bersaglio. Il grafico mostra come varia l’errore della punta. [Scarica il video MP4](https://github.com/cyborg-ai-git/0322508INGINF04_0322500142/releases/download/simulazioni-ode45-v2/manipolatore_4R.mp4)

### Robot mobile differenziale

https://github.com/user-attachments/assets/6d9b836b-87e6-41f2-ba52-40665ddc4aa3

Il filmato riproduce a velocità quadrupla i 58,4 s simulati. La mappa mostra il waypoint attivo e il percorso tra gli ostacoli. Il dettaglio del telaio e il grafico delle velocità permettono di seguire le manovre delle due ruote. [Scarica il video MP4](https://github.com/cyborg-ai-git/0322508INGINF04_0322500142/releases/download/simulazioni-ode45-v2/robot_mobile.mp4)

## Avvio in MATLAB Online o in MATLAB locale

Aprire [MATLAB Online](https://matlab.mathworks.com/) oppure avviare MATLAB sul computer. Con il pacchetto locale, estrarre `robotica_matlab.zip` e aprire la cartella `robotica_elaborati`. Per scaricare i sorgenti, clonare la [repository pubblica su GitHub](https://github.com/cyborg-ai-git/0322508INGINF04_0322500142).

### Clonare il progetto da GitHub

In MATLAB Online, eseguire `cd(matlabdrive)` nella Command Window. In locale, scegliere la cartella di lavoro e verificare che Git sia disponibile da riga di comando. Il comando seguente scarica l’ultima versione dei sorgenti e del README. I filmati sono inclusi nel pacchetto locale.

```matlab
url = 'https://github.com/cyborg-ai-git/0322508INGINF04_0322500142.git';
system(['git clone --depth 1 --branch main ' url])
cd('0322508INGINF04_0322500142')
```

### Avviare un elaborato

Dalla cartella del progetto, scegliere uno dei due blocchi. Ogni script esegue `clearvars`, chiude le figure e pulisce la Command Window prima della simulazione.

**Manipolatore planare 4R**

```matlab
addpath(fullfile(pwd, 'elaborato_4R', 'codice'))
avvia_4R
```

**Robot mobile differenziale**

```matlab
addpath(fullfile(pwd, 'elaborato_mobile_differenziale', 'codice'))
avvia_mobile
```

Dati e grafici sono nella cartella `risultati` del progetto. Per riprodurre il moto, eseguire `anima_4R(braccio)` oppure `anima_mobile(mobile)`.

## Registrare ed esportare i video

Le funzioni di animazione salvano la registrazione originale in AVI Motion JPEG nella cartella corrente. I parametri `plot.fps` e `plot.videoSpeed` del file `settings` regolano frequenza e velocità.

Dopo `avvia_4R` eseguire

```matlab
anima_4R(braccio, 1, 0, 'manipolatore_4R.avi')
```

Per riprodurre la prova articolata, dalla stessa cartella del clone eseguire

```matlab
addpath(fullfile(pwd, 'elaborato_4R', 'codice'))
articolato = simula_4R(settings_articolato_4R());
anima_4R(articolato);
```

Per registrarla, usare `anima_4R(articolato, 1, 0, 'manipolatore_4R_articolato.avi')`.

Dopo `avvia_mobile` eseguire

```matlab
anima_mobile(mobile, 1, 0, 'robot_mobile.avi')
```

Per esportare la propria registrazione nello stesso formato dei filmati pubblicati, eseguire il comando corrispondente da terminale nella cartella dell’AVI, con FFmpeg installato.

```sh
ffmpeg -i manipolatore_4R.avi -c:v libx264 -crf 16 -pix_fmt yuv420p -movflags +faststart manipolatore_4R.mp4
ffmpeg -i manipolatore_4R_articolato.avi -c:v libx264 -crf 20 -pix_fmt yuv420p -movflags +faststart manipolatore_4R_articolato.mp4
ffmpeg -i robot_mobile.avi -c:v libx264 -crf 16 -pix_fmt yuv420p -movflags +faststart robot_mobile.mp4
```

## Eseguire le simulazioni

Per lavorare con entrambi i risultati nella stessa sessione, aprire la radice della repository come cartella corrente in MATLAB e richiamare direttamente le funzioni. Eseguire i comandi seguenti nella Command Window. Il valore `false` genera tutte le figure e salva i dati. Usare `true` per riprodurre anche l’animazione completa.

```matlab
addpath(fullfile(pwd, 'elaborato_4R', 'codice'));
addpath(fullfile(pwd, 'elaborato_mobile_differenziale', 'codice'));

braccio = main_4R(false);
mobile = main_mobile(false);
```

Per riprodurre i risultati già in memoria, usare `anima_4R(braccio)` o `anima_mobile(mobile)`. Ogni progetto genera CSV, MAT e PNG nella propria cartella `risultati`. Una nuova esecuzione aggiorna i file omonimi. I parametri fisici, la durata, i guadagni e il seme PRM si trovano in [settings_4R.m](elaborato_4R/codice/settings_4R.m) e [settings_mobile.m](elaborato_mobile_differenziale/codice/settings_mobile.m).

## Modello simbolico e verifiche

```matlab
modello = derivazione_simbolica_4R();   % Energie, M, C, G e residuo di Eulero–Lagrange
verifica_simbolica_4R(modello);        % Richiede Symbolic Math Toolbox
esito4R = verifica_4R();               % Cinematica, dinamica e integrazione con ode45
esitoMobile = verifica_mobile();       % Primitive, collisioni, inseguimento e posa finale
```

Nel 4R gli angoli sono espressi in radianti e la gravità è diretta lungo −y. Per il mobile, i comandi alle ruote sono ordinati come `[omega_R; omega_L]` in rad/s. Dopo le simulazioni, `braccio.metriche` e `mobile.metriche` contengono le misure riassuntive.
