module TimeseriesMakie

using Makie
using Random

# ? Format recipe docstrings
using Makie.DocStringExtensions
import Makie: DocThemer, ATTRIBUTES, DocInstances, INSTANCES, Linestyle

import Makie: mixin_generic_plot_attributes, mixin_colormap_attributes,
              documented_attributes, attribute_names, DocumentedAttributes, automatic

function get_attrs(P::Type{<:Plot})
    # Makie.attribute_default_expressions(P)
    Makie.documented_attributes(P)
end
function drop_attrs(attrs::DocumentedAttributes, keys)
    attrs = deepcopy(attrs)
    map(collect(keys)) do key
        if haskey(attrs.d, key)
            delete!(attrs.d, key)
        end
    end
    return attrs
end
function get_drop_attrs(P::Type{<:Plot}, keys)
    attrs = get_attrs(P)
    return drop_attrs(attrs, keys)
end

MColor = Union{<:AbstractString, <:Symbol}
MakieColor = Union{<:MColor, <:Tuple{<:MColor, <:Number}}
maybecolor(x::MakieColor) = Makie.to_color(x)
maybecolor(x) = x

minmax(x) = (x .- minimum(x)) ./ (maximum(x) - minimum(x))
minmax(x::Number) = x
include("Recipes.jl")

# * Extensions
function spectrumplot end
function spectrumplot! end
function plotspectrum end
function plotspectrum! end
export spectrumplot, spectrumplot!, plotspectrum, plotspectrum!

end
