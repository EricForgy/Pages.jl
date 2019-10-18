function example_blank(nwin)
    for i = 1:nwin
        Pages.launch("http://localhost:$(Pages.port)/examples/blanks")
        wait(Pages.conditions["connected"])
    end

    Pages.broadcast("/examples/blank","say","Hello everyone!")
    for (sid,s) in Pages.connections["/examples/blank"]
        Pages.message("/examples/comms",sid,"say","You are connection #$(sid).")
    end
end
