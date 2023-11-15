%%%-------------------------------------------------------------------
%% @doc ow_example public API
%% @end
%%%-------------------------------------------------------------------

-module(ow_example_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    logger:notice("Starting and registering"),
    ow_protocol:register(
        #{
            app => ow_example,
            router => ow_example_msg,
            modules => [ow_example_zone]
        }
    ),
    ow_example_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
