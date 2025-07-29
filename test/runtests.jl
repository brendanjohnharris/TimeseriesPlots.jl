using Test
using TestItems
using TestItemRunner

@run_package_tests

@testsnippet Setup begin
    using CairoMakie
    using CairoMakie.Makie.PlotUtils
    using Statistics
    using LinearAlgebra
    using TimeseriesPlots
    using CairoMakie.Makie.Distributions
    using LaTeXStrings
end

@testitem "Kinetic" setup=[Setup] begin
    x = range(-4π, 4π, length = 10000)
    y = sinc.(x)
    f = Figure()
    ax = Axis(f[1, 1])
    kinetic!(ax, x, y; linewidthscale = 0.5, linewidth = :curv)
    display(f)
end

@testitem "Bandwidth" setup=[Setup] begin
    x = range(-4π, 4π, length = 1000)
    y = sinc.(x)
    f = Figure()
    ax = Axis(f[1, 1])
    bandwidth!(ax, x, y; bandwidth = range(0.0001, 0.1, length = length(x)))

    bandwidth!(ax, x, y .+ 0.25; bandwidth = range(0.5, 0.00, length = length(x)),
               direction = :y, alpha = 0.5)
    display(f)
end

@testitem "Trails 2D" setup=[Setup] begin
    f = Figure(size = (400, 400))

    ϕ = 0:0.1:(8π) |> reverse
    x = ϕ .* exp.(ϕ .* im)
    y = imag.(x)
    x = real.(x)

    # * Default
    ax = Axis(f[1, 1], title = "Default")
    trails!(ax, x, y)

    # * Colormap
    ax = Axis(f[1, 2], title = "Colormap")
    trails!(ax, x, y; color = 1:500)

    # * Alpha
    ax = Axis(f[2, 1], title = "Alpha^3")
    trails!(ax, x, y; alpha = Base.Fix2(^, 3))

    # * Shorter trail
    ax = Axis(f[2, 2], title = "Shorter trail")
    trails!(ax, x, y; n_points = 100)

    linkaxes!(contents(f.layout))
    hidedecorations!.(contents(f.layout))
    save("recipes/trails.png", f)

    # * Animation
    f = Figure(size = (300, 300))
    r = 50
    ax = Axis(f[1, 1], limits = ((-r, r), (-r, r)))
    xy = Observable([Point2f(first.([x, y]))])
    p = trails!(ax, xy, n_points = 100)
    hidedecorations!(ax)

    record(f, "recipes/trails_animation.mp4", zip(x, y)) do _xy
        xy[] = push!(xy[], Point2f(_xy))
    end
end
