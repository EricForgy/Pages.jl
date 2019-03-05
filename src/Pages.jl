module Pages

using HTTP, JSON, Sockets

import HTTP.WebSockets.WebSocket

export Endpoint, endpoints, Callback, HTTP
export GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH

struct Method{M} end

struct Endpoint
    handler::Function
    route::String

    function Endpoint(handle,route,method=GET)
        route = lowercase(route)
        if haskey(endpoints,route)
            e = endpoints[route]
            @eval Pages begin
                $(e).handler(m::Type{$(method)}) = HTTP.RequestHandlerFunction($(handle))
            end
            return e
        else
            function handler end
            e = new(handler,route)
            @eval Pages begin
                $(e).handler(m::Type{$(method)}) = HTTP.RequestHandlerFunction($(handle))
            end
            endpoints[route] = e
            return e
        end
    end
end
const endpoints = Dict{String,Endpoint}()
# const sessions = Dict{String,WebSocket}()

# include("callbacks.jl")
include("server.jl")
# include("api.jl")

# include("../examples/examples.jl")


function __init__()
    methods = ["GET","HEAD","POST","PUT","DELETE","CONNECT","OPTIONS","TRACE","PATCH"]
    for method in methods
        @eval Pages $(Symbol(method)) = Method{Symbol($(method))}
    end
end

end
