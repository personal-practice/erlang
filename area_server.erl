-module(area_server).
-export([start/0,area/2,rpc/2,loop/0]).

start() -> spawn(area_server, loop, []).

area(Pid, What) -> rpc(Pid, What).

rpc(Pid, What) ->
    Pid ! {self(), What},
    receive
        {Pid, Response} -> Response
    end.

loop() ->
    receive
        {From, {rectangle, Width, Height}} ->
            From ! {self(), Width * Height};
        {From, {square, Width}} ->
            From ! {self(), Width * Width};
        {From, Other} ->
            From ! {error, Other}
    end,
    loop().
