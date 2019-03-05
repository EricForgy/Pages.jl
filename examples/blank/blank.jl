Endpoint("/examples/blank") do request::HTTP.Request
    read(joinpath(@__DIR__,"blank.html"),String)
end

function example_comms(nwin)
    for i = 1:nwin
        Pages.launch("http://localhost:$(Pages.port)/examples/blanks")
        wait(Pages.conditions["connected"])
    end

    Pages.broadcast("/examples/blank","say","Hello everyone!")
    for (sid,s) in Pages.connections["/examples/blank"]
        Pages.message("/examples/comms",sid,"say","You are connection #$(sid).")
    end
end
