module Pages

using HTTP, JSON, DataFrames

import HTTP.WebSockets.WebSocket

export Endpoint, Callback

mutable struct Endpoint
    handler::Function
    route::String
    sessions::Dict{String,WebSocket}

    function Endpoint(handler,route)
        p = new(handler,route,Dict{String,WebSocket}())
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
# include("ijulia.jl")

include("../examples/examples.jl")

end
