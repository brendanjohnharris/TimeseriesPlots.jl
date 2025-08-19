# ?------------------------------------ Spike raster ------------------------------------? #
@recipe(SpikeRaster, x, y, z) do scene
    Attributes(colormap = nothing,
               color = :black,
               markersize = 5,
               sortby = false,
               rev = false)
end

function Makie.plot!(plot::SpikeRaster)
    times, order = plot.y, plot.x[]
    _is = eachindex(times[]) # Then adjust according to order

    sortby = plot.sortby[]
    if sortby == false
        order = order
    elseif sortby === :rate # ? Sort by firing rate
        maxmin = extrema(Iterators.flatten(times[])) |> collect
        order = map(times[]) do x
            length(x) ./ diff(maxmin) |> only
        end
    elseif sortby isa Function
        order = sortby.(times[])
    elseif eltype(sortby) <: Number
        order = sortby
    end

    if plot.rev[]
        order = .-order
    end
    if eltype(order) <: Number
        is = invperm(sortperm(order))
    else
        is = _is
    end

    xs = map(_is) do i
        lift(times) do x
            map(ustrip, x[i])
        end
    end
    ys = map(_is) do i
        lift(xs[i]) do x
            fill(is[i], length(x))
        end
    end
    valid_attributes = Makie.shared_attributes(plot, Scatter)

    map(_is) do i
        scatter!(plot, xs[i], ys[i]; valid_attributes...)
    end
    plot
end

function Makie.convert_arguments(P::Type{<:SpikeRaster},
                                 x::AbstractVector{<:AbstractVector})
    Makie.convert_arguments(P, 1:length(x), x)
end
