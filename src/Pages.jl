module Pages

using HttpServer, WebSockets, URIParser, JSON

export pages

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
    for (id,c) in connections
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
function message(id,msg::Dict)
    if haskey(connections,id)
        c = connections[id]
        if ~c.is_closed
            write(c, json(msg))
        end
    end
end
message(id,t,msg) = message(id,Dict("type"=>t,"data"=>msg))

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
