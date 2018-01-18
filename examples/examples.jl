using PlotlyJS

Endpoint("/libs/plotly/1.16.1/plotly.min.js") do request::Request
    readstring(joinpath(dirname(@__FILE__),"libs","plotly","v1.16.1","plotly.min.js"))
end

Endpoint("/libs/d3/4.2.1/d3.min.js") do request::Request
    readstring(joinpath(dirname(@__FILE__),"libs","d3","v4.2.1","d3.min.js"))
end

Endpoint("/examples") do request::Request
    readstring(joinpath(dirname(@__FILE__),"examples.html"))
end

include("plotly.jl")

function examples()

Endpoint("/examples/plot.ly") do request::Request
    readstring(joinpath(dirname(@__FILE__),"plotly.html"))
end

@async Pages.start()
sleep(2.0)
Pages.launch("http://localhost:$(Pages.port)/examples")

end