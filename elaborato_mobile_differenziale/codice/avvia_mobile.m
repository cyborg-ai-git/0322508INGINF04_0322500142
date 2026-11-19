% AVVIA_MOBILE Avvio dalla Command Window con un Workspace pulito.
clearvars;
close all;
clc;
% Il risultato mobile raccoglie pose, comandi alle ruote e percorso pianificato.
% Per rivedere il moto dai dati già calcolati, usare anima_mobile(mobile).
mobile = main_mobile(false);
