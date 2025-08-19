"""
    kinetic(x, y; kwargs...)

Plots a line with a varying width.

## Key attribtues:

`linewidth` = `:curv`:

Sets the algorithm for determining the line width.

- `:curv` - Width is determined by the velocity

- `:x` - Width is determined by the x-coordinate

- `:y` - Width is determined by the y-coordinate

- `<: Number` - Width is set to a constant value

`linewidthscale` = `1`: Scale factor for the line width.
"""
@recipe Kinetic (x, y) begin
    cycle = :color
    color = @inherit linecolor
    linewidth = :curv
    linewidthscale = 1

    get_drop_attrs(Density, [:cycle, :color, :linewidth])...
end

function interleave(x)
    x = [collect(x[i:(i + 1)]) for i in eachindex(x)[1:(end - 1)]]
    # append!.(x, NaN)
    vcat(x...)
end
function minter(x)
    l = map(eachindex(x)) do i
        if i == 1
            x[1]
        else
            mean(x[(i - 1):i])
        end
    end
    l = l .- minimum(l)
    l = l ./ maximum(l)
    l .*= 10
    l .+= 1
    return l[2:end]
end

function difter(x)
    l = map(eachindex(x)) do i
        if i < 2
            x[3] - 2 * x[2] + x[1]
        elseif i > length(x) - 1
            x[end - 2] - 2 * x[end - 1] + x[end]
        else
            x[i + 1] - 2 * x[i] + x[i - 1]
        end
    end
    l = exp.(-abs.(l) .^ 2)
    l = l .- minimum(l)
    l = l ./ maximum(l)
    l .*= 10
    l .+= 1
    return l[2:end]
end

function Makie.plot!(plot::Kinetic{<:Tuple{AbstractVector{<:Real}, AbstractVector{<:Real}}})
    map!(plot.attributes, [:linewidth, :x, :y, :linewidthscale],
         :linewidths) do l, x, y, lscale
        if l isa Number
            l = fill(l, length(x) - 1)
        elseif l === :x
            l = minter(x)
        elseif l === :y
            l = minter(y)
        elseif l === :curv
            l = difter(y)
        end
        [x for x in l for _ in 1:2] .* lscale
    end

    map!(plot.attributes, [:x, :y], :xy) do x, y
        map(Point2f, zip(interleave(x), interleave(y)))
    end

    linesegments!(plot, plot.attributes, plot.xy; linewidth = plot.attributes[:linewidths])
end
