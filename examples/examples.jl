using Pages,Blink

Pages.start()

Endpoint("/examples/pages") do request::Request, session::Session
    open(readall,Pkg.dir("Pages","examples","PagesJL.html"))
end

function example_pages()
    nwin = 3
    for i = 1:nwin
        w = Window(Dict(:title => "Pages: Window #$i", :url => "http://localhost:8000/examples/pages"))
        tools(w)
        wait(Pages.conditions["connected"])
    end

    Pages.broadcast("say","Hello everyone!")
    for (sid,s) in Pages.sessions
        for (cid,c) in s.connections
            Pages.message(cid,"say","You are connection #$(cid).")
        end
    end
end
example_pages()
