using CSV
using Plots

f = CSV.File(open("data/example.csv"), header=false).Column1

include("src/series.jl")
include("src/index.jl")

series = ZeroMeanSeries(f)

mutable struct JumpIdentifier
  min_length::Int
  index::Union{Set{Int}, Nothing}
  simple::Bool
  base_lambda::Float64
end

function JumpIdentifier(; min_length::Int = 2, base_lambda::Float64 = 0.0, simple::Bool = true)
  index = Set{Int}()
  return JumpIndetifier(min_length, index, simple, base_lambda)
end

function jump_indentification!(jump_id::JumpIdentifier, series::ZeroMeanSeries; starting_index = 0, top_level::Bool = true)
  if top_level
    jump_id.index = Set{Int}([0, length(series.data)])
  end
  if length(series.data) < jump_id.min_length
    return nothing
  end
  # TODO: Finish rewriting
end

# Jump identification function
function jump_identification!(data::Vector{T}, min_length::Int; starting_index::Int = 0, top_level::Bool = true, jump_index::Union{Set{Int}, Nothing} = nothing) where T
  if length(data) < min_length
    return nothing
  end
  if top_level
    jump_index = Set{Int}()
    push!(jump_index, 0)
    push!(jump_index, length(data))
  end
  series = ZeroMeanSeries(data)
  k = violating_index(series)
  push!(jump_index, starting_index + k)
  data1 = data[1:k]
  data2 = data[(k+1):end]
  jump_identification!(data1, min_length; starting_index=starting_index, top_level = false, jump_index = jump_index)
  jump_identification!(data2, min_length; starting_index=starting_index+k, top_level = false, jump_index = jump_index)
  if top_level
    println(11)
    return sort(collect(jump_index))
  end
  return nothing
end

idx = jump_identification!(f, 100)
p = plot(f, legend = false, linestyle = :dash)
# scatter!(p, idx[2:end-1], f[idx[2:end-1]])
for k in 1:(length(idx)-1)
  i1, i2 = idx[k] + 1, idx[k+1]
  sub_data = f[i1:i2]
  avg = sum(sub_data) / length(sub_data)
  plot!(p, i1:i2, fill(avg, length(i1:i2)), color = :red)
end

plot(p; dpi = 1000)
savefig("./example.png")
