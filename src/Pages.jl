module Pages

using HTTP, JSON, Documenter

export Endpoint, HTTP, JSON, Documenter
export GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE, PATCH

include("Endpoints.jl"); using .Endpoints
include("Callbacks.jl"); using .Callbacks
include("Server.jl"); using .Server
include("Messaging.jl"); using .Messaging
const broadcast = Messaging.broadcast
include("DOM.jl"); using .DOM
include("Docs.jl"); using .Docs
include("Examples/Examples.jl"); using .Examples

end
