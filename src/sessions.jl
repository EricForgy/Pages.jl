type Session
    id::AbstractString
    page::Endpoint
    connections::Dict{Int,WebSocket} # WebSocket.id => WebSocket

    function Session(page::Endpoint)
        id = uppercase(randstring(16))
        while haskey(sessions,id)
            id = uppercase(randstring(16))
        end
        s = new(id,page,Dict{Int,WebSocket}())
        sessions[id] = s
        finalizer(s, s -> delete!(sessions, s.id))
        s
    end
end
function show(io::Base.IO,session::Session)
    print(io,"Session: ",
        "\n  ID: ",session.id,
        "\n  Page: ",session.page.route,
        "\n  Connections: ", string(session.connections))
end

const sessions = Dict{AbstractString,Session}()
