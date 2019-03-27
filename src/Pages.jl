module Pages

using HTTP, JSON

import HTTP.WebSockets: WebSocket
import HTTP.Sockets: @ip_str

export Endpoint, endpoints, Callback, HTTP
export GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH

struct Method{M} end

struct Endpoint
    handlers::Dict{Symbol,HTTP.RequestHandlerFunction}
    route::String

    function Endpoint(handle,route,method::Method{M}=GET) where M
        route = lowercase(route)
        if haskey(endpoints,route)
            e = endpoints[route]
            e.handlers[M] = HTTP.RequestHandlerFunction(handle)
            return e
        else
            handlers = Dict(M=>HTTP.RequestHandlerFunction(handle))
            e = new(handlers,route)
            endpoints[route] = e
            return e
        end
    end
end
const endpoints = Dict{String,Endpoint}()
# const sessions = Dict{String,WebSocket}()

include("callbacks.jl")
include("server.jl")
include("api.jl")

include("../examples/examples.jl")

symbol(m::Type{Method{M}}) where M = M

Base.show(io::IO,m::Method{M}) where M = print(io,M)
Base.show(io::IO,::MIME"text/plain",m::Method{M}) where M = print(io,M)

methods = ["GET","HEAD","POST","PUT","DELETE","CONNECT","OPTIONS","TRACE","PATCH"]
for method in methods
    @eval Pages $(Symbol(method)) = Method{Symbol($(method))}()
end
method(m::Method{S}) where {S} = S

end
