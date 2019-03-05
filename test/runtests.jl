using Pages
using Test

methods = [GET,HEAD,POST,PUT,DELETE,CONNECT,OPTIONS,TRACE,PATCH]
for m in methods
    Endpoint("/hello",m) do request::HTTP.Request
        string(m)
    end
    e = endpoints["/hello"]
    s = Pages.symbol(m)
    @test HTTP.handle(e.handlers[s],HTTP.Request()) === string(m)
end

