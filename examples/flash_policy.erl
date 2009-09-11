-module(flash_policy). 

-export([start/0]). 

start()-> 
    {ok, Listen} = gen_tcp:listen(8843, 
                                  [binary, {reuseaddr, true}, 
                                   {active, true}, {packet, 0}]), 
    spawn(fun()-> par_connect(Listen) end). 

par_connect(Listen)-> 
    {ok, Socket} = gen_tcp:accept(Listen), 
    spawn(fun()-> par_connect(Listen) end), 
    loop(Socket). 

loop(Socket)-> 
    receive 
        {tcp, Socket, B} -> 
            error_logger:info_report(B),
            Reply = "<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\" /></cross-domain-policy>\0",
            ok = gen_tcp:send(Socket, Reply), 
            loop(Socket); 
        {tcp_closed, Socket} -> 
            io:format("server closed socket");
        Other ->
            error_logger:info_report([{other,Other}])
    end. 
