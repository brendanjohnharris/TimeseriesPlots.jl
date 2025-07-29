```@meta
CurrentModule = TimeseriesPlots
```

```@setup TimeseriesPlots
using CairoMakie
using CairoMakie.Makie.PlotUtils
using CairoMakie.Colors
using Makie
using TimeseriesPlots
```

# TimeseriesPlots

Documentation for [TimeseriesPlots](https://github.com/brendanjohnharris/TimeseriesPlots.jl); a Makie theme and some utilities.


## Default theme
```@example TimeseriesPlots
using CairoMakie
using TimeseriesPlots
TimeseriesPlots() |> Makie.set_theme!
fig = TimeseriesPlots.demofigure()
```

## Theme options
Any combination of the keywords below can be used to customise the theme.
### Dark
```@example TimeseriesPlots
TimeseriesPlots(:dark, :transparent) |> Makie.set_theme!
fig = TimeseriesPlots.demofigure()
```

### Transparent
```@example TimeseriesPlots
TimeseriesPlots(:dark, :transparent) |> Makie.set_theme!
fig = TimeseriesPlots.demofigure()
```

### Serif
```@example TimeseriesPlots
TimeseriesPlots(:serif) |> Makie.set_theme!
fig = TimeseriesPlots.demofigure()
```

### Physics
```@example TimeseriesPlots
TimeseriesPlots(:physics) |> Makie.set_theme!
fig = TimeseriesPlots.demofigure()
```