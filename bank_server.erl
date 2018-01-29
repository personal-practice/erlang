-module(bank_server).
-export([rpc/2,new_server/2]).

rpc(Pid, Request) ->
    Ref = make_ref(),
    Pid ! {{self(), Ref}, Request},
    receive
        {Ref, {crash, Reason}} -> exit(Reason);
        {Ref, {ok, Reply}} -> Reply
    end.

server(Mod, State) ->
    receive
        {Client, {new_code, NewMod}} ->
            reply(Client, ok),
            server(NewMod, State);
        {Client, Msg} ->
            case catch Mod:handle(Msg, State) of
                {'EXIT', Reason} ->
                    reply(Client, {crash, Reason}),
                    server(Mod, State);
                {Reply, NewState} ->
                    reply(Client, {ok, Reply}),
                    server(Mod, NewState)
            end
    end.

reply({ClientPid, Ref}, Response) ->
    ClientPid ! {Ref, Response}.

new_server(Name, Mod) ->
    keep_alive(fun() ->
        register(new_server, self()),
        server(Mod, Mod:init())
    end).

keep_alive(Fun) ->
    Pid = spawn(Fun),
    on_exit(Pid, fun(_) ->
        keep_alive(Fun) end).

on_exit(Pid, Fun) ->
    spawn(fun() ->
        process_flag(trap_exit, true),
        link(Pid),
        receive {'EXIT', Pid, Why} ->
            Fun(Why)
        end
    end).
