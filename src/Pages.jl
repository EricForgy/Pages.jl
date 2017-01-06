module Pages

using HttpServer, WebSockets, URIParser, Mustache, JSON, DataFrames
using Compat; import Compat: String, @static

export Endpoint, Callback, Request, URI, query_params

type Endpoint
    handler::Function
    route::String
    sessions::Dict{Int,WebSocket}

    function Endpoint(handler,route)
        p = new(handler,route,Dict{Int,WebSocket}())
        !haskey(pages,route) || warn("Page $route already exists.")
        pages[route] = p
        finalizer(p, p -> delete!(pages, p.route))
        p
    end
end
function Base.show(io::Base.IO,endpoint::Endpoint)
    print(io,"Endpoint created at $(endpoint.route).")
end
const pages = Dict{String,Endpoint}() # url => page

include("callbacks.jl")
include("server.jl")
include("api.jl")
include("ijulia.jl")

end
