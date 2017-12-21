module Pages

using HttpServer, WebSockets, URIParser, JSON, DataFrames
using Compat; import Compat: String, @static

export Endpoint, Callback, Request, Response, URI, query_params, launch

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

type Public
    handler::Function
    route::String
    path::String

    function Public(handler,route,path)
        p = new(handler,route,path)
        !haskey(public,route) || warn("Public folder $route already exists.")
        public[route] = p
        finalizer(p, p -> delete!(public, p.route))
        p
    end
end
Public(route,path) = Public(route,path) do request::Request
    file = joinpath(path,basename(URI(request.resource).path))
    isfile(file) ? readstring(file) : "File not found."
end

# function Base.show(io::Base.IO,public::Public)
#     print(io,"Public folder created at $(public.route).")
# end
const public = Dict{String,Public}() # url => public

include("callbacks.jl")
include("server.jl")
include("api.jl")
include("ijulia.jl")

end
