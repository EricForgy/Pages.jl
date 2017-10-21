type Callback
    callback::Function
    name::String

    function Callback(callback,name)
        cb = new(callback,name)
        callbacks[name] = cb
        finalizer(cb, cb -> delete!(callbacks, cb.name))
        cb
    end
end
const callbacks = Dict{String,Callback}() # name => args -> f(args...)

# Empty callback to notify the Server that a new page is loaded and its WebSocket is ready.
Callback("connected") do client
    println("New connection established (ID: $(client.id)).")
    notify(conditions["connected"])
end

# Callback used to cleanup when the browser navigates away from the page.
Callback("unloaded") do client, route
    delete!(pages[route].sessions,client.id)
end

# Callback used to message a specified connected browser.
Callback("message") do client, args
    message(args...)
end

# Callback used to broadcast to all connected browsers.
Callback("broadcast") do client, args
    broadcast(args...)
end

# Callback used for blocking Julia control flow until notified by the WebSocket.
Callback("notify") do client, name
    if haskey(conditions,name)
        notify(conditions[name])
    else
        error("""Condition "$name" was not found.""")
    end
end
