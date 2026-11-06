using CSV
using Plots

f = CSV.File(open("data/example.csv"), header=false).Column1

# Struct to hold a zero-mean time series and its cumulative sum
mutable struct ZeroMeanSeries{T}
  data::Vector{T}
  N::Int64
  cumsum::Vector{T}
  average::T
end

# Function to create a ZeroMeanSeries from a given data vector
function ZeroMeanSeries(data::Vector{T}) where T
  N = length(data)
  avg = sum(data) / N
  new_data = data .- avg
  data_cumsum = cumsum(new_data)
  return ZeroMeanSeries(new_data, N, data_cumsum, avg)
end

# Function to compute the dual total variation of a ZeroMeanSeries
dualTV(series::ZeroMeanSeries) = maximum(abs.(series.cumsum))

# Finds index where dual TV is maximized
function violating_index(series::ZeroMeanSeries)
  max_dual_tv, val, idx = -Inf, 0.0, 0
  for i in eachindex(series.data)
    val += series.data[i]
    if abs(val) > max_dual_tv
      max_dual_tv = abs(val)
      idx = i
    end
  end
  return idx
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



p

plot(p; dpi = 1000)
savefig("./example.png")
