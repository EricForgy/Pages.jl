using Pages,Blink

pages["/examples/pages"] = req -> open(readall,Pkg.dir("Pages","examples","PagesJL.html"))
conditions["connected"] = Condition()

"""Example: Pages

~~~julia
julia> include(Pkg.dir("Pages","examples","examples.jl"))
~~~

This example opens three Blink windows with their developer consoles open and introduces the connection number for each window.

For the purpose of discussion, we will assume the three connection numbers are 3,4 and 5. To follow along, use the actual connection numbers you see in the developer consoles.

### Broadcast

From the developer console for connection 3, enter:

~~~js
Pages.broadcast("say","Hello from #3")
~~~

This will broadcast `"Hello from #3"` to all connected browsers.

### Message

Next, from connection 3, enter:

~~~js
Pages.message(5,"say","Hi #5")
~~~

From connection 5, enter:

~~~js
Pages.message(3,"say","Hi #3.")
~~~

### Broadcast Scripts

You can also executes JavaScript commands. From connection 3, enter:

~~~js
Pages.broadcast("script","console.log(Math.log(10))")
~~~

or execute JavaScript commands on a specified connection.

### Message Scripts

From connection 3, enter:

~~~js
Pages.message(5,"script","console.log(Math.log(10))")
~~~

### Julia REPL

This functionality is also available from the REPL. From the REPL, enter:

~~~julia
julia> Pages.broadcast("say","Hello from the REPL")
julia> Pages.message(5,"say","Hi #5. I am the REPL")
julia> Pages.broadcast("script","console.log(Math.log(20))")
julia> Pages.message(4,"script","console.log(Math.log(30))")
~~~
"""
function example_pages()
    w1 = Window(Dict(:title => "Pages: Window #1", :url => "http://localhost:8000/examples/pages"))
    tools(w1)
    Pages.block(()->(),"connected")
    w2 = Window(Dict(:title => "Pages: Window #2", :url => "http://localhost:8000/examples/pages"))
    tools(w2)
    Pages.block(()->(),"connected")
    w3 = Window(Dict(:title => "Pages: Window #3", :url => "http://localhost:8000/examples/pages"))
    tools(w3)
    Pages.block(()->(),"connected")

    Pages.broadcast("say","Hello everyone!")
    for (id,conn) in Pages.connections
        Pages.message(id,"say","You are connection #$(id).")
    end
end
example_pages()

# """Example: Broadcast
#
#     using Pages
#
# Open multiple browsers to http://localhost:8000/examples/pages and, in each one, open the developer console.
#
#     Pages.example_broadcast()
#
# Examine the messages sent to the browser console.
# """
# function example_broadcast()
#     Pages.broadcast("Hello everyone!")
#     for (id,conn) in Pages.connections
#         Pages.message(id,"Psst. Hi connection #$(id). You are my favorite ;)")
#     end
# end
