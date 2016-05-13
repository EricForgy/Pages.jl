# Pages.jl

[![Build Status](https://travis-ci.org/EricForgy/Pages.jl.svg?branch=master)](https://travis-ci.org/EricForgy/Pages.jl)

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

julia> Pages.start();
Listening on 0.0.0.0:8000...
~~~

When launched, Pages starts a server that is listening at http://localhost:8000 and exposes a few methods.

The first:

~~~julia
julia> Endpoint("/hello") do request::Request
       "Hello world"
       end
Endpoint created at /hello.
~~~

creates a web page at http://localhost:8000/hello that says `Hello world`. A dictionary of endpoints is contained in

~~~julia
julia> Pages.pages
Dict{AbstractString,Pages.Endpoint} with 2 entries:
  "/hello"      => Endpoint created at /hello.
  "/PagesJL.js" => Endpoint created at /PagesJL.js.
~~~

Note there are two endpoints already. The one we just added plus `/PagesJL.js`. This endpoint is special and is part of Pages. It contains the JavaScript library that allows interaction between Julia and the browser. We'll discuss this in more detail below.

For safety reasons, if an endpoint is already created, Pages will throw an error if you try to create it again. For example, if we want to augment (from the REPL) the `Hello world` example above with url parameters, we'd need to first delete the old endpoint:

~~~julia
julia> delete!(Pages.pages,"/hello")
Dict{AbstractString,Pages.Endpoint} with 1 entry:
  "/PagesJL.js" => Endpoint created at /PagesJL.js.

julia> Endpoint("/hello") do request::Request
       uri = URI(request.resource)
       param = query_params(uri)
       "Hello $(param["name"])."
       end
Endpoint created at /hello.
~~~

Opening the url http://localhost:8000/hello?name=Julia now greets you with `Hello Julia`.

One nice thing about using Pages is that we can create pages whenever and wherever we want in our Julia code. The remaining dictionaries and methods are probably best explained by way of an example.

## Example

~~~julia
julia> include(Pkg.dir("Pages","examples","examples.jl"))
~~~

The first thing this example does is add a page

~~~julia
Endpoint("/examples/pages") do request::Request
    open(readall,Pkg.dir("Pages","examples","PagesJL.html"))
end
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
Dict{AbstractString,Pages.Callback} with 5 entries:
  "broadcast" => Pages.Callback((anonymous function),"broadcast")
  "message"   => Pages.Callback((anonymous function),"message")
  "connected" => Pages.Callback((anonymous function),"connected")
  "notify"    => Pages.Callback((anonymous function),"notify")
  "unloaded"  => Pages.Callback((anonymous function),"unloaded")
~~~

There are five callbacks predefined in Pages. The first two are simply:

~~~julia
# Callback used to message a specified connected browser.
Callback("message") do args
    message(args...)
end

# Callback used to broadcast to all connected browsers.
Callback("broadcast") do args
    broadcast(args...)
end
~~~

Essentially, Julia listens (via WebSocket) for a JSON string of the form

~~~js
"{\"name\":\"callback_name\",\"args\":\"callback_args\"}"
~~~

from any source/language that supports WebSockets and calls the Julia function

~~~julia
callbacks[callback_name](callback_args)
~~~

The third callback is

~~~julia
# Empty callback to notify the Server that a new page is loaded and its WebSocket is ready.
Callback("connected") do
end
~~~

This is just an empty callback used to notify Julia that a new WebSocket is connected to the server and available for communication.

The forth callback is

~~~julia
# Callback used for blocking Julia control flow until notified by the WebSocket.
Callback("notify") do name
    if haskey(conditions,name)
        notify(conditions[name])
    else
        error("""Condition "$name" was not found.""")
    end
end
~~~

The fifth callback is

~~~julia
# Callback used to cleanup when the browser navigates away from the page.
Callback("unloaded") do session_id
    session = sessions[session_id]
    delete!(pages[session.route].sessions,session_id)
    delete!(sessions,session_id)
end
~~~

### Blocking

One challenge when working with Julia and JavaScript together is that Julia will not wait for the JavaScript to complete before moving on to the next lines of code. However, sometimes you want to block the Julia flow until the JavaScript is completed.

For this, Pages provides a global dictionary

~~~julia
julia> Pages.conditions
Dict{AbstractString,Condition} with 2 entries:
  "connected" => Condition(Any[])
  "unloaded"  => Condition(Any[])
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
