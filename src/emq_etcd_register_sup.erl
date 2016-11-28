-module(emq_etcd_register_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, brutal_kill, Type, [I]}).

%% Supervisor callbacks
-export([init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  EtcdRegister = ?CHILD(emq_etcd_register, worker),
  {ok, {{one_for_one, 2, 1}, [EtcdRegister]}}.

