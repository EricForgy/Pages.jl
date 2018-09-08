# Browser Window (Borrowed from Blink.jl)
@static if Sys.isapple()
    launch(x) = run(`open $x`)
elseif Sys.islinux()
    launch(x) = run(`xdg-open $x`)
elseif Sys.iswindows()
    launch(x) = run(`cmd /C start $x`)
end

const conditions = Dict{String,Condition}()
conditions["connected"] = Condition()
conditions["unloaded"] = Condition()

port = 8000
function start(p = 8000)
    global port = p

    Endpoint("/pages.js") do request::HTTP.Request
        read(joinpath(@__DIR__,"pages.js"),String)
    end

    HTTP.listen(ip"0.0.0.0",p) do http
        if HTTP.WebSockets.is_upgrade(http.message)
            HTTP.WebSockets.upgrade(http) do client
                while !eof(client);
                    data = String(readavailable(client))
                    msg = JSON.parse(data)
                    name = pop!(msg,"name"); route = pop!(msg,"route"); id = pop!(msg,"id")
                    if haskey(callbacks,name)
                        callbacks[name].callback(client,route,id,msg)
                    end
                end
            end
        else
            HTTP.handle(router[],http)
        end
    end
end
