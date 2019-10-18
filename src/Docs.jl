module Docs

using ..Pages

export servedocs

function servedocs(modulepath;root="/",port=8000)
    makefile = normpath(joinpath(modulepath,"..","..","docs","make.jl"))
    if isequal(basename(makefile),"make.jl")
        folder = dirname(makefile)
        if isdir(joinpath(folder,"build"))
            buildfolder = joinpath(folder,"build")
            Pages.servefile(joinpath(buildfolder,"index.html"),root)
            Pages.servefile(joinpath(buildfolder,"search_index.js"))
            Pages.servefolder(joinpath(buildfolder,"assets"),"/assets")
            Pages.servefolder(joinpath(buildfolder,"search"),"/search")
        end
        @async Pages.start(port)
    else
        @warn "$(makefile) does not point to a valid make.jl"
    end
end

end # module