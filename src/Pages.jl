module Pages

using HTTP, JSON, Sockets

import HTTP.WebSockets.WebSocket

export Endpoint, Get, Post, Callback, HTTP

const router = Ref{HTTP.Router}()

struct Endpoint
    handler::Function
    method::String
    route::String

    function Endpoint(handler,method,route)
        HTTP.@register(router[],method,route,HTTP.Handlers.RequestHandlerFunction(handler))
        new(handler,method,route)
    end

    Endpoint(handler,route) = Endpoint(handler,"",route)
end

Get(handler,route) = Endpoint(handler,"GET",route)
Post(handler,route) = Endpoint(handler,"POST",route)

include("callbacks.jl")
include("server.jl")
include("api.jl")
include("displays/plotly.jl")
# include("ijulia.jl")

include("../examples/examples.jl")

function __init__()
    router[] = HTTP.Router()
end

end
