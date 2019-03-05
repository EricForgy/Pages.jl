function examples()
    Endpoint("/examples") do request::HTTP.Request
        read(joinpath(@__DIR__,"examples.html"),String)
    end

    # include(joinpath(@__DIR__,"plotly.jl"))
    include(joinpath(@__DIR__,"requests.jl"))
    include(joinpath(@__DIR__,"blank.jl"))
    # include("mwe.jl")
        
    @async Pages.start()
    Pages.launch("http://localhost:$(Pages.port)/examples")
end