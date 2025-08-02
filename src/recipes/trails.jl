@recipe Trails (x,) begin
    cycle = :linecolor

    alpha = identity
    n_points = automatic

    get_drop_attrs(Lines, [:cycle, :alpha])...
end
function Makie.plot!(plot::Trails{<:Tuple{<:Vector{<:Point}}})
    # Step 1: Parse and validate inputs
    map!(plot.attributes, [:x, :color, :colormap, :alpha, :n_points],
         [:parsed_color, :parsed_colormap, :validated_n_points]) do x, color, colormap,
                                                                    alpha, n_points
        isempty(x) && return color, colormap, 0
        N = length(x)

        # Parse color once
        parsed_color = color isa Symbol ? Makie.to_color(color) : color
        parsed_colormap = colormap isa Symbol ? cgrad(colormap) : colormap

        # Choose n_points with early returns
        if n_points === automatic
            validated_n_points = N
            # Check constraints in order of likely impact
            if !(alpha isa Function) && (length(alpha) > 1 && (eltype(alpha) <: Real))
                validated_n_points = min(validated_n_points, length(alpha))
            end
            if !(parsed_color isa Colorant) && length(parsed_color) > 1 &&
               (eltype(parsed_color) <: Real || eltype(parsed_color) <: Colorant)
                validated_n_points = min(validated_n_points, length(parsed_color))
            end
        else
            validated_n_points = max(1, min(n_points, N))
        end

        return parsed_color, parsed_colormap, validated_n_points
    end

    # Step 2: Process color data
    map!(plot.attributes, [:x, :parsed_color, :parsed_colormap, :validated_n_points],
         [:processed_color, :final_colormap]) do x, color, colormap, n_points
        isempty(x) && return Float64[], colormap

        if color isa Colorant || color isa Symbol || first(color) isa Colorant ||
           first(color) isa Symbol
            color = Makie.to_color(color)
            final_colormap = cgrad([color, color])
            processed_color = n_points == 1 ? [1.0] : range(0, 1, length = n_points)
        else
            final_colormap = colormap
            processed_color = color
        end
        # Interpolate colormap
        final_colormap = cgrad(final_colormap)
        return processed_color, final_colormap
    end

    # Step 3: Process alpha data
    map!(plot.attributes, [:alpha, :validated_n_points],
         [:processed_alpha]) do alpha, n_points
        n_points == 0 && return Float64[]

        if alpha isa Real
            alpha_vals = fill(alpha, n_points)
        elseif alpha isa Function
            alpha_vals = convert(Vector{Float32}, alpha.(1:n_points))
        else
            if length(alpha) < n_points
                # Handle insufficient alpha data
                if length(alpha) == 1
                    alpha_vals = fill(clamp(alpha[1], 0.0, 1.0), n_points)
                else
                    alpha_vals = [clamp(alpha[mod1(i, length(alpha))], 0.0, 1.0)
                                  for i in 1:n_points]
                end
            else
                alpha_vals = alpha[(end - n_points + 1):end]
            end
        end

        return (alpha_vals,)
    end

    # Step 4: Normalize data
    map!(plot.attributes, [:processed_color, :processed_alpha, :validated_n_points],
         [:normalized_color, :normalized_alpha]) do color, alpha_vals, n_points
        n_points <= 1 && return color, alpha_vals

        # Normalize alpha
        normalized_alpha = copy(alpha_vals)
        alpha_min, alpha_max = extrema(normalized_alpha)
        if alpha_max > alpha_min
            alpha_range = alpha_max - alpha_min
            normalized_alpha .= (normalized_alpha .- alpha_min) ./ alpha_range
        end

        # Normalize color
        normalized_color = color
        if !(color isa AbstractRange) && eltype(color) <: Real
            color_min, color_max = extrema(color)
            if color_max > color_min
                color_range = color_max - color_min
                normalized_color = (color .- color_min) ./ color_range
            end
        end

        return normalized_color, normalized_alpha
    end

    # Step 5: Generate final colors and trim data
    map!(plot.attributes,
         [:x, :normalized_color, :final_colormap, :normalized_alpha, :validated_n_points],
         [:trimmed_x, :c]) do x, color, colormap, alpha_vals, n_points
        isempty(x) && return x, Vector{Makie.RGBA}()
        N = length(x)

        # Handle single point case
        if n_points <= 1
            offset = min(n_points, N)
            trimmed_x = x[(end - offset + 1):end]
            if n_points == 0
                return trimmed_x, Vector{Makie.RGBA}()
            end

            base_color = colormap[0.0]
            alpha_val = length(alpha_vals) > 0 ? first(alpha_vals) : 1.0
            c = [Makie.RGBA(base_color.r, base_color.g, base_color.b,
                            clamp(alpha_val, 0.0, 1.0) * base_color.alpha)]
            return trimmed_x, c
        end

        # Sample colormap and blend alpha efficiently
        c = Vector{Makie.RGBA}(undef, n_points)
        @inbounds for i in 1:n_points
            color_idx = color isa AbstractRange ? color[i] :
                        (eltype(color) <: Real ? clamp(color[i], 0.0, 1.0) : color[i])
            base_color = colormap[color_idx]
            c[i] = Makie.RGBA(base_color.r, base_color.g, base_color.b,
                              alpha_vals[i] * base_color.alpha)
        end

        # Trim x efficiently
        offset = min(n_points, N)
        trimmed_x = @view x[(end - offset + 1):end]

        return collect(trimmed_x), c
    end

    lines!(plot, plot.attributes, plot.trimmed_x; color = plot.c, colormap = :viridis,
           alpha = 1.0)
end
Makie.convert_arguments(::Type{<:Trails}, x, y) = (Point2f.(zip(x, y)),)
Makie.convert_arguments(::Type{<:Trails}, x, y, z) = (Point3f.(zip(x, y, z)),)
