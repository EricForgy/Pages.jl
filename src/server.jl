const connections = Dict{Int,WebSocket}() # WebSocket.id => WebSocket
const conditions = Dict{AbstractString,Condition}()

Endpoint("/PagesJL.js") do request::Request, session::Session
    d = Dict("session_id" => session.id)

    template = Mustache.template_from_file(Pkg.dir("Pages","res","PagesJL.js"))
    render(template,d)

end

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
        json = bytestring(read(client))
        msg = JSON.parse(json)
        connections[client.id] = client
        sessions[msg["session_id"]].connections[client.id] = client
        haskey(msg,"args") ? callbacks[msg["name"]](msg["args"]) : callbacks[msg["name"]]()
    end
end

http = HttpHandler() do request::Request, response::Response
    route = URI(request.resource).path
    if haskey(pages,route)
        session = Session(pages[route])
        res = Response(session.page.handler(request,session))
    else
        res = "Page not found."
    end
    res
end

server = Server(http,ws)

start(port = 8000) = @async run(server, port)
