# Browser Window (Borrowed from Blink.jl)
@osx_only     launch(x) = run(`open $x`)
@linux_only   launch(x) = run(`xdg-open $x`)
@windows_only launch(x) = run(`cmd /C start $x`)

# const connections = Dict{Int,WebSocket}() # WebSocket.id => WebSocket
const conditions = Dict{AbstractString,Condition}()
conditions["connected"] = Condition()
conditions["unloaded"] = Condition()

Endpoint("/PagesJL.js") do request::Request, session::Session
    d = Dict("session_id" => session.id)
    template = Mustache.template_from_file(Pkg.dir("Pages","res","PagesJL.js"))
    render(template,d)
end

ws = WebSocketHandler() do request::Request, client::WebSocket
    while true
        msg = JSON.parse(bytestring(read(client)))
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

start(port = 8000) = @async run(server, port)
