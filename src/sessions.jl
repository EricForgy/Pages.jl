type Session
    id::AbstractString
    route::AbstractString
    client::WebSocket

    function Session(route::AbstractString)
        id = uppercase(randstring(16))
        while haskey(sessions,id)
            id = uppercase(randstring(16))
        end
        s = new(id,route)
        sessions[id] = s
        pages[route].sessions[id] = s
        s
    end
end
function show(io::Base.IO,session::Session)
    print(io,"Session: ",
        "\n  ID: ",session.id,
        "\n  Route: ",session.route)
end

const sessions = Dict{AbstractString,Session}()
