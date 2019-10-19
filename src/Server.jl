module Server

using ..Pages
import Pages.Endpoints: endpoints
import Pages.Callbacks: callbacks, conditions
import HTTP.Sockets: @ip_str

export launch, start

# Browser Window (Borrowed from Blink.jl)
@static if Sys.isapple()
    launch(x) = run(`open $x`)
elseif Sys.islinux()
    launch(x) = run(`xdg-open $x`)
elseif Sys.iswindows()
    launch(x) = run(`cmd /C start $x`)
end

conditions["connected"] = Condition()
conditions["unloaded"] = Condition()

function start(p=8000)

    Endpoint("/pages.js",GET) do request::HTTP.Request
        read(joinpath(@__DIR__,"pages.js"),String)
    end

    HTTP.listen(ip"0.0.0.0", p, readtimeout=0) do http
        route = lowercase(HTTP.URI(http.message.target).path)
        if haskey(endpoints,route)
            if HTTP.WebSockets.is_upgrade(http.message)
                HTTP.WebSockets.upgrade(http) do client
                    while !eof(client);
                        data = String(readavailable(client))
                        msg = JSON.parse(data)
                        name = pop!(msg,"name")
                        route = pop!(msg,"route")
                        id = pop!(msg,"id")
                        if haskey(callbacks,name)
                            callbacks[name].callback(client,route,id,msg)
                        end
                    end
                end
            else
                e = endpoints[route]
                m = Symbol(uppercase(http.message.method))
                HTTP.handle(e.handlers[m],http)
            end
        else
            HTTP.handle(HTTP.Handlers.FourOhFour,http)
        end
    end
    return nothing
end

end
