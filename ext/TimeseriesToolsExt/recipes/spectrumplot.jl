import TimeseriesTools: findmaxima, peakproms

@recipe SpectrumPlot (f, s) begin
    cycle = [:color]

    "Mark the prominent peaks?"
    peaks = false

    "Window size for peak finding"
    pwindow = 10

    "Annotate peak values?"
    annotate = false

    "Formatter for peak text numbers"
    textformat = identity

    "Whether to filter non-negative points"
    nonnegative = true

    textcolor = :black
    align = (:center, :bottom)

    get_drop_attrs(Lines, [:cycle])...
    get_drop_attrs(Scatter, attribute_names(Lines))...
    get_drop_attrs(Makie.Text,
                   [attribute_names(Scatter)..., attribute_names(Lines)..., :align])...
end
function Makie.plot!(plot::SpectrumPlot{<:Tuple{AbstractVector,
                                                AbstractVector}})
    map!(plot.attributes, [:f, :s, :nonnegative], [:x, :y]) do f, s, nn
        if nn
            idxs = (sign.(f) .> 0) .& (sign.(s) .> 0) # Sign for unitfuls
            return (f[idxs], s[idxs])
        else
            return (f, s)
        end
    end

    map!(plot.attributes, [:x, :y, :peaks, :pwindow], [:p]) do x, y, peaks, pwindow
        if peaks === false
            return (Point2f[],)
        end
        pks, vals = findmaxima(y, pwindow) # Ignores uneven sampling
        if peaks === true
            peaks = length(pks)
        end
        pks, proms = peakproms(pks, y)
        if peaks isa Int
            peaks = min(peaks, length(pks))
            promidxs = partialsortperm(proms, 1:peaks, rev = true)
        elseif peaks isa Real
            promidxs = (proms ./ vals .> peaks) |> collect
        else
            return (Point2f[],)
        end
        pks = pks[promidxs]
        xp = x[pks]
        yp = y[pks]
        return (Point2f.(xp, yp),)
    end

    map!(plot.attributes, [:p, :annotate, :textformat], [:t]) do p, annotate, textformat
        if annotate === false || isempty(p)
            return ([],)
        end
        if annotate === true
            annotate = (identity, nothing)
        end
        if annotate isa AbstractVector
            annotate = Tuple(annotate)
        end
        if !(annotate isa Tuple)
            annotate = (annotate, nothing)
        end
        if annotate isa Tuple
            annotate = textformat(annotate)
            text = map(p) do xy
                txt = map(annotate, xy) do a, x
                    if a isa Nothing
                        text = nothing
                    elseif a isa String || a isa Symbol
                        text = "$x $a"
                    else # a is a function probably
                        text = x |> a |> string
                    end
                end
                txt = filter(!isnothing, txt)
            end
            text = map(text) do t
                if length(t) == 1
                    return only(t)
                else
                    return "($(first(t)), $(last(t)))"
                end
            end
        end
        return (text,)
    end
    text!(plot, plot.attributes, plot[:p]; text = plot[:t], color = plot[:textcolor])
    scatter!(plot.attributes, plot.attributes[:p])
    lines!(plot, plot.attributes, plot.attributes[:x], plot.attributes[:y])
end

function Makie.convert_arguments(::Type{<:SpectrumPlot}, xy::AbstractVector{<:Point2f})
    (map(first, xy), map(last, xy))
end
function Makie.convert_arguments(::Type{<:SpectrumPlot}, x::UnivariateSpectrum)
    decompose(x)
end

function Makie.convert_arguments(::Type{<:SpectrumPlot}, x::UnivariateRegular)
    (decompose ∘ spectrum)(x)
end

# * Then do specializations for spectra, f + v + matrix, multivariate spectra, etc..

TimeseriesPlots.spectrumplot(args...; kwargs...) = spectrumplot(args...; kwargs...)
TimeseriesPlots.spectrumplot!(args...; kwargs...) = spectrumplot!(args...; kwargs...)

# * plotspectrum; modifies axis, not a recipe
"""
    plotspectrum!(ax::Axis, x::UnivariateSpectrum)
Plot the given spectrum, labelling the axes, adding units if appropriate, and other niceties.
"""
function TimeseriesPlots.plotspectrum!(ax::Makie.Axis, s::UnivariateSpectrum;
                                       nonnegative = true, kwargs...)
    uf = frequnit(s)
    ux = unit(s)
    f, s = decompose(s)
    f = ustripall.(f) |> collect
    s = ustripall.(s) |> collect
    idxs = (f .> 0) .& (s .> 0)

    ax.xscale = log10
    ax.yscale = log10
    uf == NoUnits ? (ax.xlabel = "Frequency") : (ax.xlabel = "Frequency ($uf)")
    ux == NoUnits ? (ax.ylabel = "Spectral density") :
    (ax.ylabel = "Spectral density ($ux)")
    p = spectrumplot!(ax, f[idxs], s[idxs]; nonnegative, kwargs...)

    p
end
function TimeseriesPlots.plotspectrum(s; axis = (), kwargs...)
    f = Figure()
    ax = Axis(f[1, 1]; xscale = log10, yscale = log10, axis...)
    p = TimeseriesPlots.plotspectrum!(ax, s; kwargs...)
    Makie.FigureAxisPlot(f, ax, p)
end

# """
#     plotspectrum!(ax::Axis, x::MultivariateSpectrum)
# Plot the given spectrum, labelling the axes, adding units if appropriate, and adding a band to show the iqr
# """
# function plotspectrum!(ax::Makie.Axis, x::MultivariateSpectrum;
#                        peaks = false,
#                        bandcolor = nothing,
#                        percentile = 0.25, kwargs...)
#     uf = frequnit(x)
#     ux = unit(x)
#     f, _, x = decompose(x)
#     f = ustripall.(f) |> collect
#     x = ustripall.(x) |> collect
#     xmin = minimum(x, dims = 2) |> vec
#     xmed = median(x, dims = 2) |> vec
#     σₗ = mapslices(x -> quantile(x, percentile), x, dims = 2) |> vec
#     σᵤ = mapslices(x -> quantile(x, 1 - percentile), x, dims = 2) |> vec
#     idxs = (f .> 0) .& (xmin .> 0)

#     dx = extrema(f[idxs])
#     dy = extrema(σₗ[idxs])
#     dy = (dy[1], dy[2] + (dy[2] - dy[1]) * 0.05)
#     ax.limits = (dx, dy)

#     ax.xscale = log10
#     ax.yscale = log10
#     if isempty(ax.xlabel[])
#         uf == NoUnits ? (ax.xlabel = "Frequency") : (ax.xlabel = "Frequency ($uf)")
#     end
#     if isempty(ax.ylabel[])
#         ux == NoUnits ? (ax.ylabel = "Spectral density") :
#         (ax.ylabel = "Spectral density ($ux)")
#     end
#     p = spectrumplot!(ax, ToolsArray(xmed[idxs], (𝑓(f[idxs]),)); peaks, kwargs...)
#     color = isnothing(bandcolor) ? (p.color[], 0.5) : bandcolor
#     lineattrs = [:linewidth, :alpha, :linestyle, :linecap, :joinstyle]
#     bandattrs = [k => v for (k, v) in kwargs if !(k ∈ lineattrs)]
#     _p = Makie.band!(ax, f[idxs], σₗ[idxs], σᵤ[idxs]; transparency = true, bandattrs...,
#                      color)
#     Makie.translate!(_p, 0, 0, -1.0)
#     p
# end

"""
    spectrumplot!(ax::Axis, x::AbstractVector, y::AbstractVector)
"""
# const ToolSpectrumPlot = SpectrumPlot{Tuple{<:UnivariateSpectrum}}
# argument_names(::Type{<: ToolSpectrumPlot}) = (:x,)

# function plot!(p::ToolSpectrumPlot)
#     x = collect(dims(p[:x], 𝑓))
#     y = collect(p[:x])
#     spectrumplot!(p, x, y)
#     p
# end

# """
#     plotLFPspectra(X::UnivariateTimeSeries; slope=nothing, position=Point2f([5, 1e-5]), fs=nothing, N=1000, slopecolor=:crimson, kwargs...)

# Create a line frequency power (LFP) spectra plot for the given time series `X`.

# # Arguments
# - `slope`: The power-law slope. Default is `nothing`.
# - `position`: The position of the slope label. Default is `Point2f([5, 1e-5])`.
# - `fs`: The sampling frequency. Default is `nothing`.
# - `N`: The number of frequency bins. Default is `1000`.
# - `slopecolor`: The color of the slope line. Default is `:crimson`.
# - `kwargs...`: Additional keyword arguments to be passed to the plot.
# """
# function plotLFPspectra(X::UnivariateTimeSeries; slope=nothing, position=Point2f([5, 1e-5]), fs=nothing, N=1000, slopecolor=:crimson, kwargs...)
#     times = collect(dims(X, 𝑡))
#     if isnothing(fs)
#         Δt = times[2] - times[1]
#         all(Δt .≈ diff(times)) || @warn "Violated assumption: all(Δt .≈ diff(times))"
#     else
#         Δt = 1/fs
#     end

#     P = [fp(Array(x)) for x ∈ eachcol(X)]
#     𝑓 = P[1].freq # Should be pretty much the same for all columns?
#     psd = hcat([p.power for p ∈ P]...)
#     psd = psd./(sum(psd, dims=1).*(𝑓[2] - 𝑓[1]))
#     psd = DimArray(psd, (𝑓𝑓), dims(X, :channel)))
#     fig = traces(𝑓, Array(psd); xlabel="𝑓 (Hz)", ylabel="Ŝ", title="Normalised power spectral density", smooth=1, yscale=log10, doaxis=false, domean=false, yminorgridvisible=false, kwargs...)
#     if !isnothing(slope)
#         _psd = psd[𝑓DD.Between(slope...))]
#         c, r, f = powerlawfit(_psd)
#         lines!(LinRange(slope..., 100), f(LinRange(slope..., 100)), color=slopecolor, linewidth=5)
#         text!(L"$\alpha$= %$(round(r, sigdigits=2))", position=Point2f0(position), fontsize=40)
#     end
#     return fig
# end
