using JSON

Endpoint("/examples/requests") do request::HTTP.Request
    read(joinpath(@__DIR__,"requests.html"),String)
end

Get("/examples/requests/echo") do request::HTTP.Request
    params = HTTP.queryparams(HTTP.URI(request.target).query)
    println("Body: $(params)")
    response = JSON.json(params)
end

Post("/examples/requests/echo") do request::HTTP.Request
    data = String(request.body)
    println("Parameters: $(data)")
    response = JSON.json(Dict(:data => data))
end

Get("/examples/variable/users/*") do request::HTTP.Request
    name = replace(request.target,"/examples/variable/users/"=>"")
    "Hi $(name)!"
end

# Endpoint("/api/math/rand") do request::HTTP.Request
#     uri = URI(request.resource)
#     if request.method == "GET"
#         param = query_params(uri)
#         if isempty(param)
#             response = Dict(:method => "GET", :value => rand())
#         else
#             n = min(1000,parse(Int,param["n"]))
#             response = Dict(:method => "GET", :value => rand(n))
#         end
#     end
#     if request.method == "POST"
#         param = query_params(uri)
#         response = Dict(:method => "POST", :value => rand())
#     end
#     JSON.json(response)
# end
