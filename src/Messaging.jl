module Messaging

using ..Pages
import Pages: connections

export broadcast, message, block, add_library

"""
Broadcast a message to all connected web pages to be interpreted by WebSocket listener. For example, in JavaScript:

var sock = new WebSocket('ws://'+window.location.host);
sock.onmessage = function( message ){
    var msg = JSON.parse(message.data);
    console.log(msg);
}
"""
function broadcast(route,args::Dict)
    if haskey(connections,route)
        for (cid,client) in connections[route]
            if isopen(client)
                write(client, JSON.json(args))
            end
        end
    end
end
broadcast(r,t,d) = broadcast(r,Dict("type"=>t,"data"=>d)) 

function broadcast(args::Dict)
    for route in keys(connections)
        for (cid,client) in connections[route]
            if isopen(client)
                write(client, JSON.json(args))
            end
        end
    end
end
broadcast(t,d) = broadcast(Dict("type"=>t,"data"=>d)) 
broadcast(d) = broadcast(Dict("type"=>"say","data"=>d))

"""
Send a message to the specified connection to be interpreted by WebSocket listener. For example, in JavaScript:

var sock = new WebSocket('ws://'+window.location.host);
sock.onmessage = function( message ){
    var msg = JSON.parse(message.data);
    console.log(msg);
}
"""
function message(route,args::Dict)
    id = pop!(args,"id"); 
    if haskey(connections,route) && haskey(connections[route],id)
        client = connections[route][id]
        if isopen(client)
            write(client,JSON.json(args))
        end
    end
end
message(route,mid,mtype,mdata) = message(route,Dict("id" => mid, "type" => mtype, "data" => mdata))
message(route,mid,mdata) = message(route,Dict("id" => mid, "type" => "say", "data" => mdata))

"""
Block Julia control flow until until callback["notify"](name) is called.
"""
function block(f::Function,name)
    conditions[name] = Condition()
    f()
    wait(conditions[name])
    delete!(conditions,name)
    return nothing
end

end