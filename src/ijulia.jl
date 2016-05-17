const _js_loaded = [false]

function ijulia()

# if we're in IJulia call setup the notebook js interop
if isdefined(Main, :IJulia) && Main.IJulia.inited
    # borrowed from https://github.com/plotly/plotly.py/blob/2594076e29584ede2d09f2aa40a8a195b3f3fc66/plotly/offline/offline.py#L64-L71
    # and https://github.com/JuliaLang/Interact.jl/blob/cc5f4cfd34687000bc6bc70f0513eaded1a7c950/src/IJulia/setup.jl#L15
    if !_js_loaded[1]
        session = Session()
        d = Dict("session_id" => session.id,"port" => port)
        template = Mustache.template_from_file(Pkg.dir("Pages","res","PagesJL.js"))
        const _PagesJL_js = render(template,d)

        # println(_PagesJL_js)

        display("text/html", """
        <script charset="utf-8" type='text/javascript'>
            $(_PagesJL_js)
        </script>
         <p>PagesJL.js loaded.</p>
         """)
        _js_loaded[1] = true
    end
end

end
