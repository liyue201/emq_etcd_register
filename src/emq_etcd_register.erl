-module(emq_etcd_register).

-export([start_link/0]).
-export([loop/4]).
-export([looop/0]).

start_link() ->
    io:format("start_link()~n"),

    %ok,Pid = spawn_link(?MODULE, loop, []),
    %{ok, Pid}.

    {ok, Url} = application:get_env(emq_etcd_register, etcd_url),
    io:format("etcd_url = ~p~n", [Url]),

    {ok, Key} = application:get_env(emq_etcd_register, key),
    io:format("key = ~p~n", [Key]),

    {ok, Value} = application:get_env(emq_etcd_register, value),
    io:format("value = ~p~n", [Value]),

    {ok, TTL} = application:get_env(emq_etcd_register, ttl),
    io:format("ttl = ~p~n", [TTL]),

    ok,Pid = spawn_link(?MODULE, loop, [Url, Key, Value, TTL]),
    {ok, Pid}.


looop() ->

    io:format("looop()~n"),

    TTL = 5,
    Sttl = integer_to_list(TTL),
    Url = "http://120.24.44.201:4001",
    Key = "/emq/node1",
    Value = "tcp://127.0.0.1:1883",

    httpc:request(put, {Url ++ "/v2/keys" ++ Key, [], ["application/x-www-form-urlencoded"],
            "value=" ++ Value ++ "&ttl=" ++ Sttl}, [], [], default),

    timer:sleep(trunc(TTL * 1000 / 3)),

    looop().


loop(Url, Key, Value, TTL) ->

    io:format("loop()~n"),

    %httpc:request(put, {Url, [], ["application/x-www-form-urlencoded"], "value=127.0.0.1:5555&ttl=10"}, [], [], default),

    Sttl = integer_to_list(TTL),

    httpc:request(put, {Url ++ "/v2/keys" ++ Key, [], ["application/x-www-form-urlencoded"],
        "value=" ++ Value ++ "&ttl=" ++ Sttl}, [], [], default),

    timer:sleep(trunc(TTL * 1000 / 3)),

    loop(Url, Key, Value, TTL).




