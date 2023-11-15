-module(ow_example_zone).
-behaviour(ow_zone).

-export([
    init/1,
    handle_join/3,
    handle_part/2,
    handle_part/3,
    handle_rpc/4,
    handle_tick/2
]).

-export([
    start_link/0,
    stop/0,
    join/2,
    part/1,
    part/2
]).

-define(SERVER, ?MODULE).
% 100ms
-define(DEFAULT_TICK_RATE, 100).

%% API
-rpc_client([snapshot, transfer]).
-rpc_server([join, part]).

start_link() ->
    ow_zone:start_link({local, ?SERVER}, ?MODULE, [], []).

stop() ->
    ow_zone:stop(?SERVER).

join(Msg, Session) -> ow_zone:join(?SERVER, Msg, Session).
part(Msg, Session) -> ow_zone:part(?SERVER, Msg, Session).
part(Session) -> ow_zone:part(?SERVER, Session).

init([]) ->
    State = #{},
    TickMs = ?DEFAULT_TICK_RATE,
    Config = #{tick_ms => TickMs},
    {ok, State, Config}.

handle_join(_Msg, Session, State) ->
    ID = ow_session:get_id(Session),
    logger:notice("Player ~p has joined", [ID]),
    Transfer = #{},
    logger:notice("Sending ~p state transfer ~p", [ID, transfer]),
    Reply = {{'@', [ID]}, {transfer, Transfer}},
    {Reply, ok, State}.

handle_part(_Msg, Session, State) ->
    ID = ow_session:get_id(Session),
    logger:notice("Player ~p has left", [ID]),
    {noreply, ok, State}.
handle_part(Session, State) ->
    ID = ow_session:get_id(Session),
    logger:notice("Player ~p has left", [ID]),
    {noreply, ok, State}.

handle_rpc(_Input, _Msg, _Session, State) ->
    logger:notice("Got some unknown RPC!"),
    {noreply, ok, State}.

handle_tick(_TickMs, State) ->
    Snapshot = #{},
    Reply = {'@zone', {snapshot, Snapshot}},
    {Reply, State}.
