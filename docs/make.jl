using Documenter, CycPols


DocMeta.setdocmeta!(CycPols, :DocTestSetup, :(using CycPols); recursive=true)

makedocs(;
    modules=[CycPols],
    authors="Jean Michel <jean.michel@imj-prg.fr> and contributors",
    sitename="CycPols.jl",
    format=Documenter.HTML(;
        canonical="https://jmichel7.github.io/CycPols.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jmichel7/CycPols.jl",
    devbranch="main",
)
