-module(misultin_websocket).

-export([start/0,stop/0]).

-define(WEB_SOCKET_JS_PATH,"../../web-socket-js").

start() ->
    misultin:start_link([{port, 8080}, {loop, fun(Req) -> handle_http(Req) end}]).

stop() ->
    misultin:stop().

handle_http(Req) ->
    error_logger:info_report(Req),
    case Req:get(upgrade) of
        "WebSocket" ->
            handle_ws(Req);
        _ ->
            handle(Req:get(method), Req:resource([urldecode]), Req)
    end.

handle('GET',[],Req) ->
    Req:file(?WEB_SOCKET_JS_PATH ++ "/sample.html");
handle('GET',[File],Req) ->
    error_logger:info_report(File),
    Req:file(?WEB_SOCKET_JS_PATH ++ "/" ++ File);
handle(_, Res, Req) ->
    error_logger:info_report({res,Res}),
    Req:ok([{"Content-Type", "text/plain"}], "Page not found.").


handle_ws(Req) ->
    Headers = Req:get(headers),
    Origin = proplists:get_value("Origin",Headers),

    Req:ws(head,[{"Upgrade","WebSocket"},
                 {"Connection","Upgrade"},
                 {"WebSocket-Origin",Origin},
                 {"WebSocket-Location","asdf"},
                 {"WebSocket-Protocol",Req:get(ws_protocol)}]),
    
    msg_loop(Req).


msg_loop(Req) ->
    receive
        {message,Msg} ->
            Req:ws(Msg),
            msg_loop(Req);
        Other ->
            error_logger:info_report(Other)
    end.
