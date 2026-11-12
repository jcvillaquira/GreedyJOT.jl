# Struct to hold a zero-mean time series and its cumulative sum
mutable struct ZeroMeanSeries{T}
  data::Vector{T}
  N::Int64
  average::T
end

# Function to create a ZeroMeanSeries from a given data vector
function ZeroMeanSeries(data::Vector{T}) where T
  N = length(data)
  avg = sum(data) / N
  new_data = data .- avg
  return ZeroMeanSeries(new_data, N, avg)
end

# Function to compute the dual total variation of a ZeroMeanSeries
# dualTV(series::ZeroMeanSeries) = maximum(abs.(series.cumsum))
