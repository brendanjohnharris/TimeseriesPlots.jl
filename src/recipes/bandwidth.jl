
"""
    bandwidth(x, y; kwargs...)

Plots a band of a certain width about a center line.

## Key attributes:
`bandwidth` = `1`: Vertical width of the band in data space. Can be a vector of `length(x)`.

`direction` = `:x`: The direction of the band, either `:x` or `:y`.
"""
@recipe Bandwidth (x, y) begin
    cycle = :color

    "Vertical width of the band in data space"
    bandwidth = 1
    "The direction of the band"
    direction = :x

    get_drop_attrs(Band, [:cycle, :direction])...
end
function Makie.plot!(plot::Bandwidth{<:Tuple{AbstractVector{<:Real},
                                             AbstractVector{<:Real}}})
    map!(plot.attributes, [:x, :y, :bandwidth, :direction], [:xx, :yl, :yu]) do x, y, l, d
        if d === :y
            x, y = y, x
        end
        if eltype(l) <: Number
            yl = y .- (l / 2)
            yu = y .+ (l / 2)
        else
            yl = y .- (first(l) / 2)
            yu = y .+ (last(l) / 2)
        end
        return x, yl, yu
    end
    band!(plot, plot.attributes, plot.attributes[:xx], plot.attributes[:yl],
          plot.attributes[:yu])
end
