function examples(;port=8000,launch=false)
    Endpoint("/examples") do request::HTTP.Request
        read(joinpath(@__DIR__,"examples.html"),String)
    end

    Endpoint("/libs/plotly/1.16.1/plotly.min.js") do request::HTTP.Request
        read(joinpath(@__DIR__,"libs","plotly","v1.16.1","plotly.min.js"),String)
    end
    
    Endpoint("/libs/d3/4.2.1/d3.min.js") do request::HTTP.Request
        read(joinpath(@__DIR__,"libs","d3","v4.2.1","d3.min.js"),String)
    end
    
    Endpoint("/examples/plot.ly") do request::HTTP.Request
        read(joinpath(@__DIR__,"plotly","plotly.html"),String)
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

    # Endpoint("/examples/variable/users/*") do request::HTTP.Request
    #     name = replace(request.target,"/examples/variable/users/"=>"")
    #     "Hi $(name)!"
    # end

    Endpoint("/examples/blank") do request::HTTP.Request
        read(joinpath(@__DIR__,"blank","blank.html"),String)
    end

    include(joinpath(@__DIR__,"blank","blank.jl"))
    include(joinpath(@__DIR__,"randomping","randomping.jl"))
    # include("mwe.jl")
        
    @async Pages.start()
    launch && Pages.launch("http://localhost:$(port)/examples")
    return
end