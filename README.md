# Pages.jl

This a package designed to make playing around with (err... prototyping) web applications in Julia as easy as possible.

If you have looked at the examples at [HttpServer.jl](https://github.com/JuliaWeb/HttpServer.jl) and [Mux.jl](https://github.com/JuliaWeb/Mux.jl) and find them trivially obvious, then this package is not for you (and me).

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

`pages` is a global dictionary of pages, but what is a page? All you need to know about a page is that it takes a `Request` and produces a `Response`, i.e. a function `req -> res`. Often, the response is in the form of a string, e.g. the contents of an HTML file.

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

This functionality is also available from the REPL.

~~~julia
julia> Pages.broadcast("say","Hello from the REPL")
julia> Pages.message(5,"say","Hi #5. I am the REPL")
julia> Pages.broadcast("script","console.log(Math.log(20))")
julia> Pages.message(4,"script","console.log(Math.log(30))")
~~~

## Acknowledgements

This package benefitted greatly from studying and working with [Blink.jl](https://github.com/JunoLab/Blink.jl). A lot of the functionality is shared with Blink although Pages does not require Atom and should work with any modern browser.
