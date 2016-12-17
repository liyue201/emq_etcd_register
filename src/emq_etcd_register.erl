-module(emq_etcd_register).

-export([start_link/0]).
-export([register/3]).

start_link() ->
    io:format("start_link()~n"),

    {ok, Url} = application:get_env(?MODULE, etcd_url),
    io:format("etcd_url = ~p~n", [Url]),

    {ok, RegistryDir} = application:get_env(?MODULE, registry_dir),
    io:format("RegistryDir = ~p~n", [RegistryDir]),

    {ok, NodeName} = application:get_env(?MODULE, node_name),
    io:format("NodeName = ~p~n", [NodeName]),

    {ok, NodeAddr} = application:get_env(?MODULE, node_addr),
    io:format("NodeAddr = ~p~n", [NodeAddr]),

    {ok, TTL} = application:get_env(?MODULE, ttl),
    io:format("ttl = ~p~n", [TTL]),

    ok,Pid = spawn_link(?MODULE, register, [Url ++ "/v2/keys" ++ RegistryDir ++  "/" ++ NodeName, NodeAddr, TTL]),
    {ok, Pid}.


register(KeyUrl, Value, TTL)->
    loop(KeyUrl, Value, TTL).


loop(KeyUrl, Value, TTL) ->

    io:format("loop()~n"),
    case exist(KeyUrl) of
        ok ->
            updateKey(KeyUrl, TTL);
        _ ->
            setKey(KeyUrl, Value, TTL)
    end,

    timer:sleep(trunc(TTL * 1000 / 5)),
    loop(KeyUrl, Value, TTL).


exist(KeyUrl)->
    case httpc:request(get, {KeyUrl, []}, [], []) of
        {ok, {{_, 200, _}, _, _Body}} ->
            io:format("get key value ok~n"),
            %io:format("ret=~p~n", [Body]),
            %Json = jsone:decode(Body),
            %io:format("json=~p", [Json]),
            ok;
        _ ->
            io:format("get key value error~n"),
            error
    end.


setKey(KeyUrl, Value, TTL)->
    Sttl = integer_to_list(TTL),
    httpc:request(put, {KeyUrl, [], ["application/x-www-form-urlencoded"], "value=" ++ Value ++ "&ttl=" ++ Sttl}, [], [], default),
    ok.



updateKey(KeyUrl, TTL)->
    Sttl = integer_to_list(TTL),
    httpc:request(put, {KeyUrl, [], ["application/x-www-form-urlencoded"], "&ttl=" ++ Sttl ++ "&prevExist=true"++"&refresh=true"}, [], [], default),
    ok.


