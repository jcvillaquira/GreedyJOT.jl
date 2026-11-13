using CSV
using Plots
using Revise

includet("src/series.jl")
includet("src/index.jl")
includet("src/jump.jl")

# Real data
f = CSV.File(open("data/example.csv"), header=false).Column1

# Synthetic data
f0 = [fill(-1.0, 100)..., fill(0.0, 20)..., -0.5]
f = [f0..., (-reverse(f0))...]

series = ZeroMeanSeries(f)
jump_id = JumpIdentifier(min_length = 100, base_lambda = 0.0, simple = false)
jump_identification!(jump_id, series)

pl = plot_jumps(series, jump_id)
plot(pl; dpi = 1000)
savefig("./assets/example.png")
