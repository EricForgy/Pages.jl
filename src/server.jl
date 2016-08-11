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

Endpoint("/PagesJL.js") do request::Request, session::Session
    d = Dict("session_id" => session.id,"port" => port)
    template = Mustache.template_from_file(joinpath(dirname(@__FILE__),"..","res","PagesJL.js"))
    render(template,d)
end

ws = WebSocketHandler() do request::Request, client::WebSocket
    while true
        msg = JSON.parse(String(read(client)))
        if haskey(sessions,msg["session_id"])
            session = sessions[msg["session_id"]]
            session.client = client
            haskey(msg,"args") ? callbacks[msg["name"]].callback(msg["args"]) : callbacks[msg["name"]].callback()
        end
    end
end

http = HttpHandler() do request::Request, response::Response
    route = URI(request.resource).path
    if haskey(pages,route)
        if isequal(route,"/PagesJL.js")
            if haskey(request.headers,"Referer")
                referer = URI(request.headers["Referer"]).path
                session = Session(referer)
            else
                session = Session()
            end
            res = Response(pages[route].handler(request,session))
        else
            res = Response(pages[route].handler(request))
        end
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
