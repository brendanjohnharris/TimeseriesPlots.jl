using CairoMakie
using Makie
import Makie.Linestyle
using TimeseriesPlots
using Documenter
using Documenter: Documenter
using Documenter.MarkdownAST
using Documenter.MarkdownAST: @ast
using DocumenterVitepress
using Markdown

include("docs_blocks.jl")

format = DocumenterVitepress.MarkdownVitepress(;
                                               repo = "github.com/brendanjohnharris/TimeseriesPlots.jl",
                                               devbranch = "main",
                                               devurl = "dev")

begin
    files = readdir(joinpath(@__DIR__, "src/reference"))
    names = split.(files, r"\.md$") .|> first .|> uppercasefirst
    reference = names .=> Base.joinpath.(["reference"], files)
end

makedocs(;
         authors = "brendanjohnharris <brendanjohnharris@gmail.com> and contributors",
         sitename = "TimeseriesPlots",
         format,
         pages = ["Home" => "index.md",
             "Recipes" => "recipes.md",
             "Reference" => reference])

DocumenterVitepress.deploydocs(;
                               repo = "github.com/brendanjohnharris/TimeseriesPlots.jl",
                               target = "build", # this is where Vitepress stores its output
                               branch = "gh-pages",
                               devbranch = "main",
                               push_preview = true)
