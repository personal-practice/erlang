-module(bank_logic).
-export([handle/2, init/0]).

init() -> {ok, 5000}.

handle(Msg, Balance) ->
    io:format("Msg: ~p\n\t Balance: ~p\n", [Msg, Balance]),
    case Msg of
        {deposit, N} ->
            {ok, Balance + N};
        {withdraw, N} when N =< Balance ->
             {ok, Balance - N};
        {withdraw, N} when N > Balance ->
            {{error, insufficient_funds}, Balance}
    end.
