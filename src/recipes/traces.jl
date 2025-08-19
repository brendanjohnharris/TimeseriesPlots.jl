@recipe Traces (x, y, Z) begin
    offset = 1
    spacing = nothing

    get_drop_attrs(Lines, [:color])...
end
function Makie.plot!(plot::Traces{<:Tuple{<:AbstractVector, <:AbstractVector,
                                          <:AbstractMatrix}})
    map!(plot.attributes, [:y, :Z], [:final_color]) do y, Z
        cs = repeat(y', size(Z, 1))
        cs = vcat(cs, fill(NaN, 1, size(cs, 2)))
        return (Iterators.flatten(cs) |> collect,)
    end

    map!(plot.attributes, [:Z, :spacing, :offset], [:stacked_Z]) do Z, spacing, offset
        c = zeros(size(Z, 2))
        if !isnothing(spacing)
            if spacing === :even
                # * Space is the difference between the minimum of 2 and the maximum of 1
                space = maximum([minimum(Z[:, i]) - maximum(Z[:, i - 1])
                                 for i in axes(Z, 2)[2:end]])
            end
            for i in axes(Z, 2)[2:end]
                if spacing === :close
                    space = maximum(Z[:, i - 1] .- Z[:, i])
                end
                c[i] = c[i - 1] + space * offset
            end
        end
        stacked_Z = Z .+ c'
        return (stacked_Z,)
    end

    # * Parse colors
    map!(plot.attributes, [:x, :stacked_Z], [:final_x]) do x, Z
        xys = map(eachcol(Z)) do _z
            xy = Point2f.(zip(x, _z))
            push!(xy, Point2f(NaN, NaN))
            return xy
        end
        return (vcat(xys...),)
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
