# Browser Window (Borrowed from Blink.jl)
@static if is_apple()
    launch(x) = run(`open $x`)
elseif is_linux()
    launch(x) = run(`xdg-open $x`)
elseif is_windows()
    launch(x) = run(`cmd /C start $x`)
end

# const connections = Dict{Int,WebSocket}() # WebSocket.id => WebSocket
const conditions = Dict{String,Condition}()
conditions["connected"] = Condition()
conditions["unloaded"] = Condition()

Endpoint("/pages.js") do request::HTTP.Request
    readstring(joinpath(dirname(@__FILE__),"pages.js"))
end

# ws = WebSocketHandler() do request::Request, client::WebSocket
#     while true
#         msg = JSON.parse(String(read(client)))
#         route = msg["route"]
#         if !haskey(pages[route].sessions,client.id)
#             pages[route].sessions[client.id] = client
#         end
#         haskey(msg,"args") ? callbacks[msg["name"]].callback(client,msg["args"]) : callbacks[msg["name"]].callback(client)
#     end
# end

function is_upgrade(req::HTTP.Request)
    is_get = req.method == "GET"
    # "upgrade" for Chrome and "keep-alive, upgrade" for Firefox.
    is_upgrade = HTTP.hasheader(req, "Connection", "upgrade")
    is_websockets = HTTP.hasheader(req, "Upgrade", "websocket")
    return is_get && is_upgrade && is_websockets
end

Base.convert(::Type{HTTP.Response},s::String) = HTTP.Response(200,s)

function start(p = 8000)
    global port = p
    HTTP.listen(ip"127.0.0.1",p) do http
        if is_upgrade(http.message)
            HTTP.WebSockets.upgrade(http) do client
                while !eof(client);
                    data = String(readavailable(client))
                    msg = JSON.parse(data)
                    name = pop!(msg,"name"); route = pop!(msg,"route"); id = pop!(msg,"id")
                    if !haskey(pages[route].sessions,id)
                        pages[route].sessions[id] = client
                    end
                    if haskey(callbacks,name)
                        callbacks[name].callback(client,route,id,msg)
                    end
                end
            end
        else
            route = http.message.target
            if haskey(pages,route)
                HTTP.Servers.handle_request(pages[route].handler,http)
            else
                HTTP.Servers.handle_request((req) -> HTTP.Response(404),http)
            end
        end
    end
end
