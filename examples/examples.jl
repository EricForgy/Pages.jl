Endpoint("/examples") do request::Request
    readstring(joinpath(dirname(@__FILE__),"examples.html"))
end

include("plotly.jl")
include("requests.jl")

function examples()

@async Pages.start()
sleep(2.0)
Pages.launch("http://localhost:$(Pages.port)/examples")

end