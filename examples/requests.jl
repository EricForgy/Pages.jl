using JSON

Endpoint("/examples/requests") do request::HTTP.Request
    readstring(joinpath(dirname(@__FILE__),"requests.html"))
end

Endpoint("/examples/requests/echo") do request::HTTP.Request
    if request.method == "GET"
        params = HTTP.queryparams(HTTP.URI(request.target).query)
        println("Body: $(params)")
        response = JSON.json(params)
    elseif request.method == "POST"
        data = String(request.body)
        println("Parameters: $(data)")
        response = JSON.json(Dict(:data => data))
    end
    response
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
