function a = angolo_pi(a)
    % ANGOLO_PI Avvolge gli angoli in [-pi,pi] senza richiedere toolbox.
    % Seno e coseno identificano la stessa direzione dopo ogni giro.
    % Per esempio, un errore di 359 gradi equivale a -1 grado.
    a = atan2(sin(a), cos(a));
end
