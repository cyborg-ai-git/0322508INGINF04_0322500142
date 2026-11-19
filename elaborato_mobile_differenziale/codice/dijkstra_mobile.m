function [path, costo] = dijkstra_mobile(W, start, goal)
    % DIJKSTRA_MOBILE Cammino minimo su grafo orientato con pesi non negativi.
    % W(i,j)=Inf indica arco assente; se il goal e' disconnesso restituisce [].
    N = size(W, 1);
    % dist(v) è il miglior tempo trovato per arrivare a v. prev(v) ricorda
    % il nodo da cui proviene il percorso che ha prodotto quel tempo.
    dist = inf(N, 1);
    prev = zeros(N, 1);
    visit = false(N, 1);
    dist(start) = 0;
    for it = 1:N
        tent = dist;
        tent(visit) = inf;
        % Con pesi non negativi il minimo tra i nodi aperti ha costo definitivo.
        % Se è Inf, nessun altro nodo è raggiungibile dalla partenza.
        [best, u] = min(tent);
        if isinf(best)
            break
        end
        if u == goal
            break
        end
        visit(u) = true;
        vicini = find(isfinite(W(u, :)) & ~visit.');
        for v = vicini
            nuova = dist(u) + W(u, v);
            if nuova < dist(v)
                dist(v) = nuova;
                prev(v) = u;
            end
        end
    end
    costo = dist(goal);
    path = [];
    if isinf(costo)
        return
    end
    % Si risale dal goal seguendo i predecessori. Anteponendo ogni nodo,
    % path viene restituito nell’ordine di percorrenza, da start a goal.
    path = goal;
    while path(1) ~= start
        padre = prev(path(1));
        assert(padre > 0, 'Catena predecessori non valida.');
        path = [padre, path];
    end
end
