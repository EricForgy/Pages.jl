# Pages.jl

[![][travis-img]][travis-url] [![][appveyor-img]][appveyor-url]

This is a package designed to help get started with web APIs and some basic interaction between Julia and a browser.

## Installation

To get the latest tagged version, try:

~~~julia
pkg> add Pages
~~~

However, this package is still in early development and is likely to change often. To get the latest, try:

~~~julia
pkg> add Pages#master
~~~

## Introduction

To get started, try the following:

~~~julia
julia> using Pages

julia> @async Pages.start();
Listening on 0.0.0.0:8000...
~~~

This starts a server that is listening at http://localhost:8000 and exposes the `Endpoint` type with a few methods.

To create an `Endpoint`, try:

~~~julia
julia> Endpoint("/hello") do request::HTTP.Request
          "Hello world"
       end
~~~

This creates a web page at http://localhost:8000/hello that says `Hello world`. 

One nice thing about using `Pages` is that we can create pages whenever and wherever we want in our Julia code even while the server is running.

## Examples

There are a few examples included.

~~~julia
julia> Pages.examples();
~~~

This will start a server and launch a browser open to a page with links to some simple examples.

Current examples include:

  - Requests - Send GET and POST requests from the browser to Julia and print the contents to the REPL.
  - Blank - You can use this for experimemntation, e.g. use `Pages.add_library` to insert your favorite JavaScript library.
  - Random Ping - For this example, click the "Blank" link and run 

  ```julia
julia> Pages.randomping()
  ```


## Callbacks

`Pages` comes with a small JavaScript library `pages.js` that allows communication between Julia and the browser as well as communication between browsers, e.g. chat, using WebSockets.

For example, consider the function

```julia
function add_library(url)
    name = basename(url)
    block(name) do
        Pages.broadcast("script","""
            var script = document.createElement("script");
            script.charset = "utf-8";
            script.type = "text/javascript";
            script.src = "$(url)";
            script.onload = function() {
                Pages.notify("$(name)");
            };
            document.head.appendChild(script);
        """)
    end
end
```

This adds a library to the head of any connected web pages. However, Julia execution is blocked until the JavaScript library is successfully loaded and sends a notification back to Julia via a callback.

## Acknowledgements

This package benefitted greatly from studying and working with [Blink.jl](https://github.com/JunoLab/Blink.jl). A lot of the functionality is shared with Blink although Pages does not require Electron and should work with any modern browser.

[travis-img]: https://travis-ci.org/EricForgy/Pages.jl.svg?branch=master
[travis-url]: https://travis-ci.org/EricForgy/Pages.jl

[appveyor-img]: https://ci.appveyor.com/api/projects/status/github/EricForgy/Pages.jl?branch=master&svg=true
[appveyor-url]: https://ci.appveyor.com/project/EricForgy/pages-jl