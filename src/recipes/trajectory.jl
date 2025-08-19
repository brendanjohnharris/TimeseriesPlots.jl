using LinearAlgebra

@recipe Trajectory (x,) begin
    """The coloring method for the trajectory"""
    color = :velocity

    get_drop_attrs(Lines, [:color])...
end
Makie.conversion_trait(::Type{<:Trajectory}) = Makie.PointBased()

function Makie.plot!(plot::Trajectory{<:Tuple{<:Vector{<:Point}}})
    map!(plot.attributes, [:color, :x], [:parsed_color]) do color, x
        if color === :speed
            if length(x) > 1
                parsed_color = map(norm, diff(x))
                prepend!(parsed_color, parsed_color[1])
            else
                parsed_color = fill(0.0f0, length(x))
            end
        elseif color === :time
            parsed_color = 1:length(x)
        else
            parsed_color = color
        end
        return (parsed_color,)
    end
    lines!(plot, plot.attributes, plot.x; color = plot.parsed_color)
end
Makie.convert_arguments(::Type{<:Trajectory}, x, y) = (Point2f.(zip(x, y)),)
Makie.convert_arguments(::Type{<:Trajectory}, x, y, z) = (Point3f.(zip(x, y, z)),)
