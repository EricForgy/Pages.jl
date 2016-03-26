module Pages

using HttpServer, WebSockets, URIParser, Mustache, JSON

import Base: show

export pages, Endpoint, Session, Request

type Endpoint
    handler::Function
    route::AbstractString

    function Endpoint(handler,route)
        p = new(handler,route)
        !haskey(pages,route) || error("Page $route already exists.")
        pages[route] = p
        finalizer(p, p -> delete!(pages, p.route))
        p
    end
end
const pages = Dict{AbstractString,Endpoint}() # url => page

include("sessions.jl")
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
        for (cid,c) in s.connections
            if ~c.is_closed
                write(c, json(msg))
            end
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
function message(cid,msg::Dict)
    if haskey(connections,cid)
        c = connections[cid]
        if ~c.is_closed
            write(c, json(msg))
        end
    end
end
message(cid,t,msg) = message(cid,Dict("type"=>t,"data"=>msg))

"""
Empty callback to notify the Server that a new page is loaded and its WebSocket is ready.
"""
callbacks["connected"] = () -> ()

"""
Callback used to message a specified connected browser.
"""
callbacks["message"] = args -> begin
    message(args...)
end

"""
Callback used to broadcast to all connected browsers.
"""
callbacks["broadcast"] = args -> begin
    broadcast(args...)
end

"""
Callback used for blocking Julia control flow until notified by the WebSocket.
"""
callbacks["notify"] = name -> begin
    if haskey(conditions,name)
        notify(conditions[name])
    else
        error("""Condition "$name" was not found.""")
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
