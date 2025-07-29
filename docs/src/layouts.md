```@meta
CurrentModule = TimeseriesPlots
```

```@setup TimeseriesPlots
using CairoMakie
using CairoMakie.Makie.PlotUtils
using CairoMakie.Colors
using Makie
using TimeseriesPlots
using Makie.IntervalSets
showable(::MIME"text/plain", ::AbstractVector{C}) where {C<:Colorant} = false
showable(::MIME"text/plain", ::PlotUtils.ContinuousColorGradient) = false
```

# Layouts

Reproducible figure sizes designed for A4 portrait documents.

## Subdivide

```@docs
subdivide
```

## Panels

### OnePanel

```@example TimeseriesPlots
f = OnePanel()
gs = subdivide(f, 1, 1)
addlabels!(gs)
f
```

### TwoPanel

```@example TimeseriesPlots
f = TwoPanel()
gs = subdivide(f, 1, 2)
addlabels!(gs)
f
```

### FourPanel

```@example TimeseriesPlots
f = FourPanel()
gs = subdivide(f, 2, 2)
addlabels!(gs)
f
```

### SixPanel

```@example TimeseriesPlots
f = SixPanel()
gs = subdivide(f, 3, 2)
addlabels!(gs)
f
```
