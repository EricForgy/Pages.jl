function examples()
    Endpoint("/examples") do request::HTTP.Request
        read(joinpath(@__DIR__,"examples.html"),String)
    end

    # include(joinpath(@__DIR__,"plotly.jl"))
    include(joinpath(@__DIR__,"requests","requests.jl"))
    include(joinpath(@__DIR__,"blank","blank.jl"))
    # include("mwe.jl")
    
    port = 8000
    @async Pages.start(port)
end