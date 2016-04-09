# const connections = Dict{Int,WebSocket}() # WebSocket.id => WebSocket
const conditions = Dict{AbstractString,Condition}()

Endpoint("/PagesJL.js") do request::Request, session::Session
    d = Dict("session_id" => session.id)
    template = Mustache.template_from_file(Pkg.dir("Pages","res","PagesJL.js"))
    render(template,d)
end
conditions["connected"] = Condition()
conditions["unloaded"] = Condition()

"""
A dictionary of callbacks accessible from the server's WebSocket listener. For example:

With a callback

    callback["say"] = args -> println(args...)

when the WebSocket listener receives a JSON string

    {"name": "say","args": "Hello World"}

it will print "Hello World" to the REPL.
"""
const callbacks = Dict{AbstractString,Function}() # name => args -> f(args...)

ws = WebSocketHandler() do request::Request, client::WebSocket
    while true
        msg = JSON.parse(bytestring(read(client)))
        if haskey(sessions,msg["session_id"])
            session = sessions[msg["session_id"]]
            session.client = client
            haskey(msg,"args") ? callbacks[msg["name"]](msg["args"]) : callbacks[msg["name"]]()
        end
    end
end

http = HttpHandler() do request::Request, response::Response
    route = URI(request.resource).path
    if haskey(pages,route)
        if isequal(route,"/PagesJL.js")
            referer = URI(request.headers["Referer"]).path
            session = Session(referer)
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
