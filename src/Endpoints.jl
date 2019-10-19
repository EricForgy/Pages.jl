module Endpoints

using ..Pages

export Endpoint, endpoints, method, servefile, servefolder
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

symbol(m::Type{Method{M}}) where M = M

Base.show(io::IO,m::Method{M}) where M = print(io,M)
Base.show(io::IO,::MIME"text/plain",m::Method{M}) where M = print(io,M)

methods = ["GET","HEAD","POST","PUT","DELETE","CONNECT","OPTIONS","TRACE","PATCH"]
for method in methods
    @eval Endpoints $(Symbol(method)) = Method{Symbol($(method))}()
end
method(m::Method{S}) where {S} = S

function servefile(filepath,root="/")
    if isfile(filepath)
        file = basename(filepath)
        if isequal(lowercase(file),"index.html") || isequal(lowercase(file),"index.htm")
            Endpoint(root) do request::HTTP.Request
                read(filepath,String)
            end
        end
        Endpoint("$(root)/$(file)") do request::HTTP.Request
            read(filepath,String)
        end
    else
        @warn "$(filepath) not found."
    end
end

function servefolder(folder,root="/")
    for file in readdir(folder)
        filepath = joinpath(folder,file)
        servefile(filepath,root)
    end
end

end
