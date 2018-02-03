"""
Broadcast a message to all connected web pages to be interpetted by WebSocket listener. For example, in JavaScript:

var sock = new WebSocket('ws://'+window.location.host);
sock.onmessage = function( message ){
    var msg = JSON.parse(message.data);
    console.log(msg);
}
"""
function broadcast(route,args::Dict)
    if haskey(pages,route)
        for (cid,client) in pages[route].sessions
            if isopen(client)
                write(client, json(args))
            end
        end
    end
end
broadcast(r,t,d) = broadcast(r,Dict("type"=>t,"data"=>d)) 

function broadcast(args::Dict)
    for key in keys(pages)
        for (cid,client) in pages[key].sessions
            if isopen(client)
                write(client, json(args))
            end
        end
    end
    for (cid,client) in external
        if isopen(client)
            write(client, json(args))
        end
    end
end
broadcast(t,d) = broadcast(Dict("type"=>t,"data"=>d)) 
"""
Send a message to the specified connection to be interpetted by WebSocket listener. For example, in JavaScript:

var sock = new WebSocket('ws://'+window.location.host);
sock.onmessage = function( message ){
    var msg = JSON.parse(message.data);
    console.log(msg);
}
"""
function message(route,args::Dict)
    id = pop!(args,"id"); 
    if haskey(pages,route)
        sessions = pages[route].sessions
        if haskey(sessions,id)
            client = sessions[id]
            if isopen(client)
                write(client,json(args))
            end
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
    return nothing
end

"""Add a JS library to the current page from a url."""
function add_library(url)
    name = basename(url)
    block(name) do
        Pages.broadcast("script","""
            var script = document.createElement("script");
            script.charset = "utf-8";
            script.type = "text/javascript";
            script.src = "$(url)";
            script.onload = function() {
                Pages.notify("$(name)");
            };
            document.head.appendChild(script);
        """)
    end
end

mutable struct Element
    id::String
    tag::String
    name::String
    attr::Dict{String,String}
    style::Dict{String,String}
    html::String
    text::String
    parent::String

    function Element(;id = "",tag = "div",name = "element",attr = Dict{String,String}(),style = Dict{String,String}(),html = "",text = "",parent = "body")
        new(id,tag,name,attr,style,html,text,parent)
    end
end

function assign(io::IO,element::Element)
    # ==========================================================================
    # Add attributes to element
    for prop in ["attr","style"]
        field = getfield(element,Symbol(prop))
        for key in keys(field)
            print(io,"""
                $(element.name).$(prop)("$(key)","$(field[key])");
            """)
        end
    end
    # ==========================================================================
    # Add html & text to element
    for prop in ["html","text"]
        field = getfield(element,Symbol(prop))
        if !isempty(field)
            print(io,"""
                $(element.name).$(prop)("$(field)");
            """)
        end
    end
    io
end

function add(io::IO,element::Element)
    # ==========================================================================
    # Get or create element
    print(io,"""
        var parent = d3.select("$(element.parent)")
        var $(element.name) = null;
    """)
    if !isempty(element.id)
        print(io,"""
            var check = document.getElementById("$(element.id)");
            if (check === null) {
                $(element.name) = parent.append("$(element.tag)").attr("id","$(element.id)");
            } else {
                $(element.name) = d3.select("#$(element.id)");
            };
        """)
    else
        print(io,"""
            $(element.name) = d3.select("$(element.parent)").append("$(element.tag)");
        """)
    end
    assign(io,element)
end
function add(element::Element)
    Pages.broadcast("script",String(take!(add(IOBuffer(),element))))
end

function append(io::IO,element::Element;parent = """d3.select("body")""")
    if isempty(element.name)
        print(io,"""
            $(parent).append("$(element.tag)");
        """)
    else
        print(io,"""
            $(element.name) = $(parent).append("$(element.tag)");
        """)
    end
    assign(io,element)
end

function remove(io::IO,tag;parent = """d3.select("body")""")
    print(io,"""
        $(parent).selectAll("$(tag)").remove();
    """)
    io
end
function remove(tag;parent = """d3.select("body")""")
    Pages.broadcast("script",String(take!(remove(IOBuffer(),tag,parent=parent))))
end

function add_select(io::IO,options,element::Element)
    element.tag == "select" || return warn("Element must have tag = select.")
    add(io,element)
    remove(io,"option",parent=element.name)
    # print(io,"""
    #     $(element.name).selectAll("option").remove();
    # """)
    for key in keys(options)
        print(io,"""
            $(element.name).append("option").attr("value","$(key)").text("$(options[key])");
        """)
    end
    io
end
function add_select(options,element::Element)
    Pages.broadcast("script",String(take!(add_select(IOBuffer(),options,element))))
end

# function add_table(io::IO,df::DataFrame;table = Element(tag="table",name="table"),tr = Element(tag="tr",name="row"),th = Element(tag="th",name="header"),td = Element(tag="td",name="cell"))
#     table.tag == "table" || return warn("Element must have tag = table.")
#     tr.tag == "tr" || return warn("Element must have tag = tr.")
#     th.tag == "th" || return warn("Element must have tag = th.")
#     td.tag == "td" || return warn("Element must have tag = td.")
#     add(io,table)
#     remove(io,"tr",parent=table.name)
#     # ==========================================================================
#     # Add header
#     print(io,"""
#         var $(tr.name) = null;
#     """)
#     append(io,tr,parent=table.name)
#     print(io,"""
#         var $(th.name) = null;
#     """)
#     for name in names(df)
#         th.html = string(name)
#         append(io,th,parent=tr.name)
#     end
#     # ==========================================================================
#     # Add data
#     print(io,"""
#         var $(td.name) = null;
#     """)
#     for irow in 1:size(df,1)
#         row = df[irow,:]
#         append(io,tr,parent=table.name)
#         for name in names(df)
#             td.html = string(row[name][1])
#             append(io,td,parent=tr.name)
#         end
#     end
#     io
# end
# function add_table(df::DataFrame;table = Element(tag="table",name="table"),tr = Element(tag="tr",name="row"),th = Element(tag="th",name="header"),td = Element(tag="td",name="cell"))
#     Pages.broadcast("script",String(take!(add_table(IOBuffer(),df,table=table,tr=tr,th=th,td=td))))
# end
