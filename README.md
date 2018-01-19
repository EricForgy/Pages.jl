# Pages.jl

[![][travis-img]][travis-url] [![][appveyor-img]][appveyor-url]

This a package designed to help get started with web APIs some basic interaction between Julia and a browser.

## Installation

~~~julia
julia> Pkg.add("Pages")
~~~

## Introduction

~~~julia
julia> using Pages

julia> @async Pages.start();
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
Dict{String,Pages.Endpoint} with 2 entries:
  "/hello"      => Endpoint created at /hello.
  "/pages.js" => Endpoint created at /pages.js.
~~~

Note there are two endpoints already. The one we just added plus `/pages.js`. This endpoint is special and is part of Pages. It contains the JavaScript library that allows interaction between Julia and the browser. We'll discuss this in more detail below.

One nice thing about using Pages is that we can create pages whenever and wherever we want in our Julia code. The remaining dictionaries and methods are probably best explained by way of an example.

## Examples

There are a few examples included.

~~~julia
julia> Pages.examples()
~~~

This will start a server and launch a browser open to a page with links to some examples.

To be continued...

## Acknowledgements

This package benefitted greatly from studying and working with [Blink.jl](https://github.com/JunoLab/Blink.jl). A lot of the functionality is shared with Blink although Pages does not require Electron and should work with any modern browser.

[travis-img]: https://travis-ci.org/EricForgy/Pages.jl.svg?branch=master
[travis-url]: https://travis-ci.org/EricForgy/Pages.jl

[appveyor-img]: https://ci.appveyor.com/api/projects/status/github/EricForgy/Pages.jl?branch=master&svg=true
[appveyor-url]: https://ci.appveyor.com/project/EricForgy/pages-jl