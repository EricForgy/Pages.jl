using Pages,Blink

using Compat; import Compat.readstring

Pages.start()

Endpoint("/examples/pages") do request::Request
    readstring(joinpath(dirname(@__FILE__),"pages.html"))
end

function example_pages()
    nwin = 3
    for i = 1:nwin
        w = Window(Dict(:title => "Pages: Window #$i", :url => "http://localhost:8000/examples/pages"))
        tools(w)
        wait(Pages.conditions["connected"])
    end

    Pages.broadcast("say","Hello everyone!")
    for (sid,s) in Pages.pages["/examples/pages"].sessions
        Pages.message(s,"say","You are connection #$(s.id).")
    end
end
# example_pages()