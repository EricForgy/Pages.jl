using Pages
using Test

methods = [GET,HEAD,POST,PUT,DELETE,CONNECT,OPTIONS,TRACE,PATCH]
for m in methods
    Endpoint("/hello",m) do request::HTTP.Request
        string(m)
    end
    e = Pages.endpoints["/hello"]
    @test HTTP.handle(e.handlers[Pages.method(m)],HTTP.Request()) === string(m)
end

