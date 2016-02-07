const pages = Dict{AbstractString,Function}() # url => req -> response
const connections = Dict{Int,WebSocket}() # WebSocket.id => WebSocket
const conditions = Dict{AbstractString,Condition}()

conditions["connected"] = Condition()

pages["/PagesJL.js"] = req -> open(readall,Pkg.dir("Pages","res","PagesJL.js"))

"""
A dictionary of callbacks accessible from the server's WebSocket listener. For example:

With a callback

    callback["say"] = args -> println(args...)

when the WebSocket listener receives a JSON string

    {"name": "say","args": "Hello World"}

it will print "Hello World" to the REPL.
"""
const callbacks = Dict{AbstractString,Function}() # name => args -> f(args...)

ws = WebSocketHandler() do req::Request, client::WebSocket
    while true
        connections[client.id] = client
        json = bytestring(read(client))
        msg = JSON.parse(json)
        if haskey(msg,"args") && haskey(msg,"name")
            callbacks[msg["name"]](msg["args"])
        elseif haskey(msg,"name")
            callbacks[msg["name"]]()
        end
    end
end

http = HttpHandler() do req::Request, res::Response
    page = URI(req.resource).path
    if haskey(pages,page)
        res = Response(pages[page](req))
    end
    res
end

server = Server(http,ws)

@async run(server, 8000)
