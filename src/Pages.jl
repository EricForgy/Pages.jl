module Pages

using HttpServer, WebSockets, URIParser, Mustache, JSON, DataFrames
using Compat; import Compat: String, @static

export Endpoint, Session, Callback, Request, URI, query_params

type Session
    id::String
    route::String
    client::WebSocket

    function Session(route::String)
        id = uppercase(randstring(16))
        while haskey(sessions,id)
            id = uppercase(randstring(16))
        end
        s = new(id,route)
        sessions[id] = s
        pages[route].sessions[id] = s
        s
    end

    function Session()
        id = uppercase(randstring(16))
        while haskey(sessions,id)
            id = uppercase(randstring(16))
        end
        s = new(id)
        sessions[id] = s
        s
    end
end
function Base.show(io::Base.IO,session::Session)
    print(io,"Session: ",
        "\n  ID: ",session.id,
        "\n  Route: ",isdefined(session,:route) ? session.route : "")
end
const sessions = Dict{String,Session}()

type Endpoint
    handler::Function
    route::String
    sessions::Dict{String,Session}

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
include("ijulia.jl")

end
