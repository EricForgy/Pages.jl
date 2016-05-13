type Callback
    callback::Function
    name::AbstractString

    function Callback(callback,name)
        cb = new(callback,name)
        callbacks[name] = cb
        finalizer(cb, cb -> delete!(callbacks, cb.name))
        cb
    end
end
const callbacks = Dict{AbstractString,Callback}() # name => args -> f(args...)

# Empty callback to notify the Server that a new page is loaded and its WebSocket is ready.
Callback("connected") do
end

# Callback used to cleanup when the browser navigates away from the page.
Callback("unloaded") do session_id
    session = sessions[session_id]
    delete!(pages[session.route].sessions,session_id)
    delete!(sessions,session_id)
end

# Callback used to message a specified connected browser.
Callback("message") do args
    message(args...)
end

# Callback used to broadcast to all connected browsers.
Callback("broadcast") do args
    broadcast(args...)
end

# Callback used for blocking Julia control flow until notified by the WebSocket.
Callback("notify") do name
    if haskey(conditions,name)
        notify(conditions[name])
    else
        error("""Condition "$name" was not found.""")
    end
end
