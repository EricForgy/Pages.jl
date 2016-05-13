module Pages

using HttpServer, WebSockets, URIParser, Mustache, JSON

export pages, Endpoint, Session, Request, URI, query_params

type Session
    id::AbstractString
    route::AbstractString
    client::WebSocket

    function Session(route::AbstractString)
        id = uppercase(randstring(16))
        while haskey(sessions,id)
            id = uppercase(randstring(16))
        end
        s = new(id,route)
        sessions[id] = s
        pages[route].sessions[id] = s
        s
    end

    function Session()
        id = uppercase(randstring(16))
        while haskey(sessions,id)
            id = uppercase(randstring(16))
        end
        new(id)
    end
end
function Base.show(io::Base.IO,session::Session)
    print(io,"Session: ",
        "\n  ID: ",session.id,
        "\n  Route: ",isdefined(session,:route) ? session.route : "")
end
const sessions = Dict{AbstractString,Session}()

type Endpoint
    handler::Function
    route::AbstractString
    sessions::Dict{AbstractString,Session}

    function Endpoint(handler,route)
        p = new(handler,route,Dict{AbstractString,WebSocket}())
        !haskey(pages,route) || error("Page $route already exists.")
        pages[route] = p
        finalizer(p, p -> delete!(pages, p.route))
        p
    end
end
function Base.show(io::Base.IO,endpoint::Endpoint)
    print(io,"Endpoint created at $(endpoint.route).")
end
const pages = Dict{AbstractString,Endpoint}() # url => page

include("callbacks.jl")
include("server.jl")

"""
Broadcast a message to all connected web pages to be interpetted by WebSocket listener. For example, in JavaScript:

var sock = new WebSocket('ws://'+window.location.host);
sock.onmessage = function( message ){
    var msg = JSON.parse(message.data);
    console.log(msg);
}
"""
function broadcast(msg::Dict)
    for (sid,s) in sessions
        c = s.client
        if ~c.is_closed
            write(c, json(msg))
        end
    end
end
broadcast(t,msg) = broadcast(Dict("type"=>t,"data"=>msg))

"""
Send a message to the specified connection to be interpetted by WebSocket listener. For example, in JavaScript:

var sock = new WebSocket('ws://'+window.location.host);
sock.onmessage = function( message ){
    var msg = JSON.parse(message.data);
    console.log(msg);
}
"""
function message(client::WebSocket,msg::Dict)
    if ~client.is_closed
        write(client, json(msg))
    end
end
message(client::WebSocket,t,msg) = message(client,Dict("type"=>t,"data"=>msg))
function message(id::Int,t,msg)
    for (sid,s) in sessions
        if isequal(id,s.client.id)
            message(s.client,Dict("type"=>t,"data"=>msg))
        end
    end
end

"""
Block Julia control flow until until callback["notify"](name) is called.
"""
function block(f::Function,name)
    conditions[name] = Condition()
    f()
    wait(conditions[name])
    delete!(conditions,name)
end

end
