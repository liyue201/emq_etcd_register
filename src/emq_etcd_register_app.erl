-module(emq_etcd_register_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    inets:start(),
    emq_etcd_register_sup:start_link().

stop(_State) ->
    ok.
