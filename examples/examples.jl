Endpoint("/examples") do request::HTTP.Request
    readstring(joinpath(dirname(@__FILE__),"examples.html"))
end

Endpoint("/examples/pages") do request::HTTP.Request
    readstring(joinpath(dirname(@__FILE__),"pages.html"))
end

include("plotly.jl")
include("requests.jl")
# include("mwe.jl")

function examples()

@async Pages.start()
sleep(2.0)
Pages.launch("http://localhost:$(Pages.port)/examples")

end
