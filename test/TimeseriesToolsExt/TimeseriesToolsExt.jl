@testsnippet ToolsSetup begin
    using CairoMakie
    using DSP
    using Unitful
    using TimeseriesTools
end

@testitem "Tools default" setup=[ToolsSetup] begin
    x = colorednoise(0.1:0.1:12)
    p = plot(x)
    @test p isa Makie.Lines
end
