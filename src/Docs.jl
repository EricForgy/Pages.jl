module Docs

using ..Pages

export servedocs

function make(modulepath=@__FILE__;build="")
    makefile = normpath(joinpath(modulepath,"..","..","docs","make.jl"))
    if isfile(makefile) && isequal(basename(makefile),"make.jl")
        buildfolder = joinpath(dirname(makefile),build)
        if isfile(joinpath(buildfolder,"index.html"))
            Base.Filesystem.rm(joinpath(buildfolder,"index.html"))
            Base.Filesystem.rm(joinpath(buildfolder,"search_index.js"))
            Base.Filesystem.rm(joinpath(buildfolder,"assets"),recursive=true)
            Base.Filesystem.rm(joinpath(buildfolder,"search"),recursive=true)
        end

        include(makefile)
    else
        @warn "$(makefile) is not a valid makefile."
    end
end

function servedocs(modulepath=@__FILE__;root="/",port=8000,build="")
    makefile = normpath(joinpath(modulepath,"..","..","docs","make.jl"))
    if isequal(basename(makefile),"make.jl")
        folder = dirname(makefile)
        if isdir(joinpath(folder,build))
            buildfolder = joinpath(folder,build)
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