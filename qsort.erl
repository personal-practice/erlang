-module(qsort).
-export([qsort/1, pqsort/1, psort/1, psortt/2]).

% Sequential
qsort([]) -> [];
qsort([X|Xs]) ->
    qsort([Y || Y <- Xs, Y < X])
    ++ [X]
    ++ qsort([Y || Y <- Xs, Y >=X]).

% Parallel
pqsort([]) -> [];
pqsort([X|Xs]) ->
    Parent = self(),
    spawn_link(fun() ->
       Parent ! pqsort([Y || Y <- Xs, Y >=X])
    end),
    pqsort([Y || Y <- Xs, Y < X])
    ++ [X]
    ++ receive Ys -> Ys end.

% Parallel II
psort(Xs) -> psortt(5, Xs).

psortt(0, Xs) -> qsort(Xs);
psortt(_, []) -> [];
psortt(D, [X|Xs]) ->
    Parent = self(),
    Gr = [Y || Y <- Xs, Y >=X],
    spawn_link(fun() ->
       Parent ! psortt(D-1, Gr)
    end),
    psortt(D-1, [Y || Y <- Xs, Y < X])
    ++ [X]
    ++ receive Ys -> Ys end.
