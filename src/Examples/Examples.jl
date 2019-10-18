module Examples

using ..Pages

export examples

function examples(;port=8000,launch=false)
    Endpoint("/examples") do request::HTTP.Request
        read(joinpath(@__DIR__,"examples.html"),String)
    end

    Endpoint("/examples/requests") do request::HTTP.Request
        read(joinpath(@__DIR__,"requests","requests.html"),String)
    end

    Endpoint("/examples/requests/echo") do request::HTTP.Request
        params = HTTP.queryparams(HTTP.URI(request.target).query)
        println("Body: $(params)")
        response = JSON.json(params)
    end

    Endpoint("/examples/requests/echo",POST) do request::HTTP.Request
        data = String(request.body)
        println("Parameters: $(data)")
        response = JSON.json(Dict(:data => data))
    end

    Endpoint("/examples/blank") do request::HTTP.Request
        read(joinpath(@__DIR__,"blank","blank.html"),String)
    end

    include(joinpath(@__DIR__,"blank","blank.jl"))
    include(joinpath(@__DIR__,"randomping","randomping.jl"))

    @async Pages.start(port)
    launch && Pages.launch("http://localhost:$(port)/examples")
    return
end

end