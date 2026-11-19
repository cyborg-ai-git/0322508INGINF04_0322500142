% AVVIA_4R Avvio dalla Command Window con un Workspace pulito.
clearvars;
close all;
clc;
% Il risultato braccio raccoglie tempi, angoli, coppie e posizione della punta.
% Per rivedere il moto dai dati già calcolati, usare anima_4R(braccio).
braccio = main_4R(false);
