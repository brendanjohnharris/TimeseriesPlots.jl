module TimeseriesToolsExt
using TimeseriesTools
using TimeseriesTools.Unitful
using Makie
using TimeseriesPlots
import TimeseriesPlots: get_drop_attrs
import Makie: attribute_names

"""
    decompose(x::Union{<:AbstractTimeSeries, <:AbstractSpectrum})
Convert a time series or spectrum to a tuple of the dimensions and the data (as `Array`s).
"""
function Makie.GeometryBasics.decompose(x::AbstractToolsArray)
    return map(parent, lookup(x))..., parent(x)
end

Makie.plottype(::AbstractTimeSeries) = Lines

function Makie.convert_arguments(::Type{<:AbstractPlot}, x::AbstractTimeSeries)
    decompose(x)
end

include("recipes/spectrumplot.jl")

end
