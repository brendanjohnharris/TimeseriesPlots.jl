using Pkg
Pkg.activate(tempname())
Pkg.add(url = "https://github.com/brendanjohnharris/TimeseriesPlots.jl")
Pkg.add("CairoMakie")

using CairoMakie
using TimeseriesPlots

begin # * Static plots
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
    save("trail.png", f)
end

begin # * Animation
    f = Figure(size = (300, 300))
    r = 50
    ax = Axis(f[1, 1], limits = ((-r, r), (-r, r)))
    xy = Observable([Point2f([NaN, NaN])])
    p = trail!(ax, xy, n_points = 100, colormap = cgrad(:turbo), color = 1:100)
    hidedecorations!(ax)

    record(f, "trail_animation.mp4", zip(x, y)) do _xy
        xy[] = push!(xy[], Point2f(_xy))
    end
end
