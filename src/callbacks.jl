mutable struct Callback
    callback::Function
    name::String

    function Callback(callback,name)
        cb = new(callback,name)
        callbacks[name] = cb
        cb
    end
end
const callbacks = Dict{String,Callback}() # name => args -> f(args...)

const connections = Dict{String,Dict{String,WebSocket}}()

# Callback to notify the Server that a new page is loaded and its WebSocket is ready.
Callback("connected") do client, route, id, data
    if haskey(connections,route)
        connections[route][id] = client
    else
        connections[route] = Dict(id => client)
    end
    println("New connection established (ID: $(id)).")
    notify(conditions["connected"])
end

# Callback used to cleanup when the browser navigates away from the page.
Callback("unloaded") do client, route, id, data
    delete!(connections[route],id)
end

# Callback used to message a specified connected browser.
Callback("message") do client, route, id, data
    message(route,data["args"])
end

# Callback used to broadcast to all connected browsers.
Callback("broadcast") do client, route, id, data
    broadcast(route,data["args"])
end

# Callback used for blocking Julia control flow until notified by the WebSocket.
Callback("notify") do client, route, id, data
    name = data["args"]
    if haskey(conditions,name)
        notify(conditions[name])
    else
        @warn "Condition '$name' was not found."
    end
end
