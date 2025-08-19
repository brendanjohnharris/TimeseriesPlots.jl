@recipe Traces (x, y, Z) begin
    get_drop_attrs(Lines, [:color])...
end
function Makie.plot!(plot::Traces{<:Tuple{<:AbstractVector, <:AbstractVector,
                                          <:AbstractMatrix}})
    # * Parse colors
    map!(plot.attributes, [:x, :Z], [:final_x]) do x, Z
        xys = map(eachcol(Z)) do _z
            xy = Point2f.(zip(x, _z))
            push!(xy, Point2f(NaN, NaN))
            return xy
        end
        return (vcat(xys...),)
    end
    map!(plot.attributes, [:y, :Z], [:final_color]) do y, Z
        cs = repeat(y', size(Z, 1))
        cs = vcat(cs, fill(NaN, 1, size(cs, 2)))
        return (Iterators.flatten(cs) |> collect,)
    end
    # map!(plot.attributes, [:color, :colormap],
    #      [:parsed_color, :parsed_colormap]) do color, colormap
    #     if color isa AbstractVector{<:Number} # One color for each line
    #         colormap = cgrad(colormap)
    #     else
    #         parsed_color = color
    #     end

    #     return parsed_color, parsed_colormap # To be sampled after calculating points
    # end
    # Main.@infiltrate
    lines!(plot, plot.attributes, plot.final_x, color = plot.final_color)
end
