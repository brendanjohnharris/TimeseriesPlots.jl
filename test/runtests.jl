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

@testitem "Trail 2D" setup=[Setup] begin
    f = Figure(size = (400, 400))

    ϕ = 0:0.1:(8π) |> reverse
    x = ϕ .* exp.(ϕ .* im)
    y = imag.(x)
    x = real.(x)

    # * Default
    ax = Axis(f[1, 1], title = "Default")
    trail!(ax, x, y)

    # * Colormap
    ax = Axis(f[1, 2], title = "Colormap")
    trail!(ax, x, y; color = 1:500)

    # * Alpha
    ax = Axis(f[2, 1], title = "Alpha^3")
    trail!(ax, x, y; alpha = Base.Fix2(^, 3))

    # * Shorter trail
    ax = Axis(f[2, 2], title = "Shorter trail")
    trail!(ax, x, y; n_points = 100)

    linkaxes!(contents(f.layout))
    hidedecorations!.(contents(f.layout))
    save("recipes/trail.png", f)

    # * Animation
    f = Figure(size = (300, 300))
    r = 50
    ax = Axis(f[1, 1], limits = ((-r, r), (-r, r)))
    xy = Observable([Point2f(first.([x, y]))])
    p = trail!(ax, xy, n_points = 100)
    hidedecorations!(ax)

    record(f, "recipes/trail_animation.mp4", zip(x, y)) do _xy
        xy[] = push!(xy[], Point2f(_xy))
    end
end

@testitem "Trajectory" setup=[Setup] begin
    f = Figure(size = (400, 400))

    ϕ = 0:0.1:(8π) |> reverse
    x = ϕ .* exp.(ϕ .* im)
    y = imag.(x)
    x = real.(x)

    # * Default
    ax = Axis(f[1, 1], title = "Default")
    trajectory!(ax, x, y)

    # * Speed
    ax = Axis(f[1, 2], title = "Speed")
    trajectory!(ax, x, y; color = :speed)

    # * Alpha
    ax = Axis(f[2, 1], title = "Time")
    trail!(ax, x, y; color = :time)

    # * 3D
    ax = Axis3(f[2, 2], title = "3D")
    trajectory!(ax, x, y, x .* y; color = :speed)

    hidedecorations!.(contents(f.layout))
    save("recipes/trajectory.png", f)

    # * Animation
    f = Figure(size = (300, 300))
    r = 50
    ax = Axis(f[1, 1], limits = ((-r, r), (-r, r)))
    X = Point3f.(zip(x, y, x .* y))
    xyz = Observable(X[[1]])
    p = trajectory!(ax, xyz, color = :speed)
    hidedecorations!(ax)

    record(f, "recipes/trajectory_animation.mp4", X) do _xyz
        xyz[] = push!(xyz[], _xyz)
    end
end

@testitem "Shadows" setup=[Setup] begin
    f = Figure(size = (200, 200))

    ϕ = 0:0.1:(8π) |> reverse
    x = ϕ .* exp.(ϕ .* im)
    y = imag.(x)
    x = real.(x)
    z = x .* y

    # * Default
    limits = (extrema(x), extrema(y), extrema(z))
    ax = Axis3(f[1, 1]; title = "Shadows", limits)
    lines!(ax, x, y, z)
    shadows!(ax, x, y, z; limits, linewidth = 0.5)

    hidedecorations!.(contents(f.layout))
    save("recipes/shadows.png", f)

    # * Animation
    f = Figure(size = (200, 200))
    ax = Axis3(f[1, 1]; limits)
    X = Point3f.(zip(x, y, z))
    xyz = Observable(X[[1]])
    lines!(ax, xyz)
    shadows!(ax, xyz; limits, color = :gray, linewidth = 0.1)
    hidedecorations!(ax)

    record(f, "recipes/shadows_animation.mp4", X) do _xyz
        xyz[] = push!(xyz[], _xyz)
    end
end

@testitem "Traces" setup=[Setup] begin
    f = Figure(size = (800, 200))

    x = 0:0.1:10
    y = range(0, π, length = 5)
    Z = [sin.(x .+ i) for i in y]
    Z = stack(Z)

    ax = Axis(f[1, 1]; title = "Unstacked")
    p = traces!(ax, x, y, Z)
    Colorbar(f[1, 2], p)

    ax = Axis(f[1, 3]; title = "Even")
    p = traces!(ax, x, y, Z; spacing = :even, offset = 1.5)
    Colorbar(f[1, 4], p)

    ax = Axis(f[1, 5]; title = "Close")
    p = traces!(ax, x, y, Z; spacing = :close, offset = 1.5)
    Colorbar(f[1, 6], p)

    save("recipes/traces.png", f)
end
