"""
Broadcast a message to all connected web pages to be interpetted by WebSocket listener. For example, in JavaScript:

var sock = new WebSocket('ws://'+window.location.host);
sock.onmessage = function( message ){
    var msg = JSON.parse(message.data);
    console.log(msg);
}
"""
function broadcast(msg::Dict)
    for (sid,s) in sessions
        c = s.client
        if ~c.is_closed
            write(c, json(msg))
        end
    end
end
broadcast(t,msg) = broadcast(Dict("type"=>t,"data"=>msg))

"""
Send a message to the specified connection to be interpetted by WebSocket listener. For example, in JavaScript:

var sock = new WebSocket('ws://'+window.location.host);
sock.onmessage = function( message ){
    var msg = JSON.parse(message.data);
    console.log(msg);
}
"""
function message(client::WebSocket,msg::Dict)
    if ~client.is_closed
        write(client, json(msg))
    end
end
message(client::WebSocket,t,msg) = message(client,Dict("type"=>t,"data"=>msg))
function message(id::Int,t,msg)
    for (sid,s) in sessions
        if isequal(id,s.client.id)
            message(s.client,Dict("type"=>t,"data"=>msg))
        end
    end
end

"""
Block Julia control flow until until callback["notify"](name) is called.
"""
function block(f::Function,name)
    conditions[name] = Condition()
    f()
    wait(conditions[name])
    delete!(conditions,name)
end

"""Add a JS library to the current page from a url."""
function add_library(url)
    name = basename(url)
    block(name) do
        broadcast("script","""
            var script = document.createElement("script");
            script.src = "$(url)";
            script.onload = Pages.notify("$(name)");
            document.head.appendChild(script);
        """)
    end
end

function add_div(id)
    Pages.broadcast("script","""
        var div = document.getElementById("$(id)");
        if (div === null) {
            d3.select("body").append("div").attr("id","$(id)").attr("class","js-plotly-plot");
        };
    """)
end
