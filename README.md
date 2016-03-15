# Pages.jl

This a package designed to make playing around with (err... prototyping) web applications in Julia as easy as possible.

If you have looked at the examples at [HttpServer.jl](https://github.com/JuliaWeb/HttpServer.jl) and [Mux.jl](https://github.com/JuliaWeb/Mux.jl) and find them trivially obvious, then this package is probably not for you.

With Pages, you do not need to know anything about HttpServers or WebSockets to get started with some basic interaction between Julia and a browser.

## Installation

~~~julia
julia> Pkg.add("Pages")
~~~

## Introduction

~~~julia
julia> using Pages
Listening on 0.0.0.0:8000...
~~~

When launched, Pages starts a server that is listening at http://localhost:8000 and exposes a few global variables and methods. The first:

~~~julia
julia> pages
Dict{AbstractString,Function} with 1 entry:
  "/PagesJL.js" => (anonymous function)
~~~

`pages` is a global dictionary of named pages, but what is a page? All you need to know about a page is that it takes a `Request` and produces a `Response`, i.e. a function `req -> res`. Often, the response is in the form of a string, e.g. the contents of an HTML file.

Pages comes with one page already defined, i.e. `"/PagesJL.js"`. Here is the [definition](https://github.com/CoherentCapital/Pages.jl/blob/master/src/server.jl#L7):

~~~julia
pages["/PagesJL.js"] = req -> open(readall,Pkg.dir("Pages","res","PagesJL.js"))
~~~

In one simple line, this says:

1. If a request is sent, e.g. from your browser, to http://localhost:8000/PagesJL.js
2. Take the request `req` and
3. Return the contents of < your Julia package directory >/Pages/res/PagesJL.js

Try it by opening the link in your browser (after `using Pages`).

One nice thing about this is that we can now create pages whenever and wherever we want in our Julia code. The remaining global variables and methods are probably best explained by way of an example.

## Example

~~~julia
julia> include(Pkg.dir("Pages","examples","examples.jl"))
~~~

The first thing this example does is add a page

~~~julia
pages["/examples/pages"] = req -> open(readall,Pkg.dir("Pages","examples","PagesJL.html"))
~~~

Note again that a page can be added from anywhere in your Julia code and is immediately available in the browser.

The example then opens three Blink windows to this page with their developer consoles open and introduces the connection number for each window with a greeting in the console.

### Broadcast

For the purpose of discussion, we will assume the three connection numbers are 3,4 and 5. To follow along, use the actual connection numbers you see in the developer consoles.

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

You can also execute JavaScript commands. From connection 3, enter:

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

This functionality is also available from the REPL.

~~~julia
julia> Pages.broadcast("say","Hello from the REPL")
julia> Pages.message(5,"say","Hi #5. I am the REPL")
julia> Pages.broadcast("script","console.log(Math.log(20))")
julia> Pages.message(4,"script","console.log(Math.log(30))")
~~~

### Callbacks

The JavaScript methods `broadcast` and `message` above are implemented as callbacks in Julia. Similar to `pages`, callbacks are stored in a global dictionary

~~~julia
julia> Pages.callbacks
Dict{AbstractString,Function} with 4 entries:
  "broadcast" => (anonymous function)
  "message"   => (anonymous function)
  "notify"    => (anonymous function)
~~~

There are three callbacks predefined in Pages. The first two are simply:

~~~julia
callbacks["broadcast"] = args -> broadcast(args...)
callbacks["message"] = args -> message(args...)
~~~

Essentially, Julia listens (via WebSocket) for a JSON string of the form

~~~js
"{\"name\":\"cbname\",\"args\":\"cbargs\"}"
~~~

and calls the Julia function

~~~julia
callbacks[cbname](cbargs)
~~~

The example adds a forth callback

~~~julia
callbacks["connected"] = () -> ()
~~~

This is just an empty callback used to notify Julia that a new WebSocket is connected to the server and available for communication.

### Blocking

One challenge when working with Julia and JavaScript together is that Julia will not wait for the JavaScript to complete before moving on to the next lines of code. However, sometimes you want to block the Julia flow until the JavaScript is completed.

For this, Pages provides a global dictionary

~~~julia
julia> Pages.conditions
Dict{AbstractString,Condition} with 0 entries
~~~

of named conditions and the Julia function

~~~julia
function block(f::Function,name)
    conditions[name] = Condition()
    f()
    wait(conditions[name])
    delete!(conditions,name)
end
~~~

`block` executes the function `f` and waits until the named condition is notified.

From JavaScript, this notification is accomplished with the function

~~~js
Pages.notify(name)
~~~

## Other Languages

Although Pages was built with interactivity between Julia and a browser via JavaScript in mind, Pages can also facilitate interactivity between Julia and any other language that supports WebSockets.

## Acknowledgements

This package benefitted greatly from studying and working with [Blink.jl](https://github.com/JunoLab/Blink.jl). A lot of the functionality is shared with Blink although Pages does not require Electron and should work with any modern browser.
