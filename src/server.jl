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

Endpoint("/pages.js") do request::Request
    readstring(joinpath(dirname(@__FILE__),"pages.js"))
end

ws = WebSocketHandler() do request::Request, client::WebSocket
    while true
        msg = JSON.parse(String(read(client)))
        route = msg["route"]
        if !haskey(pages[route].sessions,client.id)
            pages[route].sessions[client.id] = client
        end
        haskey(msg,"args") ? callbacks[msg["name"]].callback(client,msg["args"]) : callbacks[msg["name"]].callback(client)
    end
end

http = HttpHandler() do request::Request, response::Response
    route = URI(request.resource).path
    if haskey(pages,route)
        res = Response(pages[route].handler(request))
    elseif haskey(public,dirname(route))
        res = Response(public[dirname(route)].handler(request))
    else
        res = "Page not found."
    end
    res
end

server = Server(http,ws)

function start(p = 8000)
    global port = p
    @async run(server, port)
end
