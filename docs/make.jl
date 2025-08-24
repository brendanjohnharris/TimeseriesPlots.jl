using CairoMakie
using Makie
import Makie.Linestyle
using TimeseriesMakie
using Documenter
using Documenter: Documenter
using Documenter.MarkdownAST
using Documenter.MarkdownAST: @ast
using DocumenterVitepress
using Markdown

include("docs_blocks.jl")

format = DocumenterVitepress.MarkdownVitepress(;
                                               repo = "github.com/brendanjohnharris/TimeseriesMakie.jl",
                                               devbranch = "main",
                                               devurl = "dev")

makedocs(;
         authors = "brendanjohnharris <brendanjohnharris@gmail.com> and contributors",
         sitename = "TimeseriesMakie",
         format,
         warnonly = [:cross_references],
         modules = [TimeseriesMakie],
         pages = ["Home" => "index.md",
             "Recipes" => "recipes.md",
             "Reference" => "reference.md"])

DocumenterVitepress.deploydocs(;
                               repo = "github.com/brendanjohnharris/TimeseriesMakie.jl",
                               target = "build", # this is where Vitepress stores its output
                               branch = "gh-pages",
                               devbranch = "main",
                               push_preview = true)
