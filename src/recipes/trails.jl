@recipe Trails (x,) begin
    cycle = :linecolor

    alpha = identity
    n_points = automatic

    get_drop_attrs(Lines, [:cycle, :alpha])...
end
function Makie.plot!(plot::Trails{<:Tuple{<:Vector{<:Point}}})
    map!(plot.attributes, [:x, :color, :colormap, :alpha, :n_points],
         [:trimmed_x, :c]) do x, color, colormap, alpha, n_points
        isempty(x) && return x, Vector{Makie.RGBA}()
        N = length(x)

        # * Parse color
        if color isa Symbol
            color = Makie.to_color(color)
        end
        if colormap isa Symbol
            colormap = cgrad(colormap)
        end

        # * Choose n_points
        if n_points === automatic
            n_points = N

            if !(color isa Colorant) && length(color) > 1 &&
               (eltype(color) <: Real || eltype(color) <: Colorant)
                n_points = min(n_points, length(color))
            end
            if length(colormap) > 1 &&
               (eltype(colormap) <: Real || eltype(colormap) <: Colorant)
                n_points = min(n_points, length(colormap))
            end
            if !(alpha isa Function) && (length(alpha) > 1 && (eltype(alpha) <: Real))
                n_points = min(n_points, length(alpha))
            end
        end
        n_points = min(n_points, N)

        # * Initalize color
        if color isa Colorant
            colormap = cgrad([color, color])
            color = 1:n_points
        end

        # * Parse alpha
        if alpha isa Real
            alpha = fill(alpha, n_points)
        elseif alpha isa Function
            alpha = alpha.(1:n_points)
        end
        alpha = alpha[(end - n_points + 1):end]

        # * Normalize colors
        if n_points > 1
            alpha = alpha .- minimum(alpha)
            alpha = alpha ./ maximum(alpha)
            color = color .- minimum(color)
            color = color ./ maximum(color)
        end

        # * Sample colormap and blend alpha
        c = colormap[color]
        c = map(alpha, c) do a, b
            Makie.RGBA(b.r, b.g, b.b, a * b.alpha)
        end

        # * Ensure lengths match
        offset = min(n_points, N)
        trimmed_x = x[(end - offset + 1):end]
        return (trimmed_x, c)
    end
    lines!(plot, plot.attributes, plot.trimmed_x; color = plot.c, colormap = :viridis,
           alpha = 1.0)
end
Makie.convert_arguments(::Type{<:Trails}, x, y) = (Point2f.(zip(x, y)),)
Makie.convert_arguments(::Type{<:Trails}, x, y, z) = (Point3f.(zip(x, y, z)),)
