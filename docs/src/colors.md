```@meta
CurrentModule = TimeseriesPlots
```

```@setup TimeseriesPlots
using CairoMakie
using CairoMakie.Makie.PlotUtils
using CairoMakie.Colors
using Makie
using TimeseriesPlots
showable(::MIME"text/plain", ::AbstractVector{C}) where {C<:Colorant} = false
showable(::MIME"text/plain", ::PlotUtils.ContinuousColorGradient) = false
```

# Colors

The TimeseriesPlots colors are `cornflowerblue`, `crimson`, `cucumber`, `california`, `juliapurple`.

```@example TimeseriesPlots
TimeseriesPlots.colors
```

# Colormaps

## Sunrise

```@example TimeseriesPlots
sunrise # hide
```

## Cyclic Sunrise

```@example TimeseriesPlots
cyclicsunrise # hide
```

## Sunset

```@example TimeseriesPlots
sunset # hide
```

## Dark Sunset

```@example TimeseriesPlots
darksunset # hide
```

## Light Sunset

```@example TimeseriesPlots
lightsunset # hide
```

## Binary Sunset

```@example TimeseriesPlots
binarysunset # hide
```

## Cyclic

```@example TimeseriesPlots
cyclic # hide
```

## Pelagic

```@example TimeseriesPlots
pelagic # hide
```