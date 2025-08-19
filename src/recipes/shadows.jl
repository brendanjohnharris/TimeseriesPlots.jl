@recipe Shadows (x,) begin
    """The shadowing mode"""
    mode = :projection

    """Whether to swap the axes for each shadow"""
    swapshadows = automatic

    """The targeted axis limits"""
    limits = automatic

    get_drop_attrs(Lines, [])...
end
Makie.conversion_trait(::Type{<:Shadows}) = Makie.PointBased()

function Makie.plot!(plot::Shadows{<:Tuple{<:Vector{<:Point3}}})
    map!(plot.attributes, [:x, :mode, :swapshadows, :limits],
         [:xs, :ys, :zs]) do x, mode, swapshadows, limits
        _x = map(Base.Fix2(getindex, 1), x)
        _y = map(Base.Fix2(getindex, 2), x)
        _z = map(Base.Fix2(getindex, 3), x)

        N = length(x)
        if swapshadows === false
            swapshadows = fill(false, 3)
        end
        if swapshadows === automatic
            swapshadows = [true, true, false]
        end
        planes = map(limits, swapshadows) do l, s
            p = s ? last(l) .+ eps() : first(l) .- eps()
            return fill(p, N)
        end
        if mode === :projection
            xs = map(Point3f, zip(planes[1], _y, _z))
            ys = map(Point3f, zip(_x, planes[2], _z))
            zs = map(Point3f, zip(_x, _y, planes[3]))
        else
            throw(ArgumentError("Unsupported shadow mode: $mode"))
        end
        return (xs, ys, zs)
    end

    lines!(plot, plot.attributes, plot.xs)
    lines!(plot, plot.attributes, plot.ys)
    lines!(plot, plot.attributes, plot.zs)
end
Makie.convert_arguments(::Type{<:Shadows}, x, y, z) = (Point3f.(zip(x, y, z)),)
