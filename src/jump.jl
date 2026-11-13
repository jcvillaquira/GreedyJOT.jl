mutable struct JumpIdentifier
  min_length::Int
  index::Union{Set{Int}, Nothing}
  simple::Bool
  base_lambda::Float64
  lambda::Float64
  variable_lambda::Bool
end

function JumpIdentifier(; min_length::Int = 2, base_lambda::Float64 = 0.0, simple::Bool = true, variable_lambda::Bool = false)
  index = Set{Int}()
  lambda = base_lambda
  return JumpIdentifier(min_length, index, simple, base_lambda, lambda, variable_lambda)
end

function get_lambda(jump_id::JumpIdentifier, series::ZeroMeanSeries)
  if jump_id.variable_lambda
    return jump_id.lambda * length(series.data)
  end
  return jump_id.base_lambda
end

function jump_identification!(jump_id::JumpIdentifier, series::ZeroMeanSeries; starting_index = 0, top_level::Bool = true)
  if top_level
    jump_id.lambda = jump_id.base_lambda / length(series.data)
    jump_id.index = Set{Int}([0, length(series.data)])
  end
  if length(series.data) < jump_id.min_length
    return nothing
  end
  lambda = get_lambda(jump_id, series)
  k = argmax_index(series; lambda = lambda, simple = jump_id.simple)
  if isnothing(k)
    return nothing
  end
  push!(jump_id.index, starting_index + k)
  series1 = ZeroMeanSeries(series.data[1:k])
  jump_identification!(jump_id, series1; starting_index = starting_index, top_level = false)
  series2 = ZeroMeanSeries(series.data[(k+1):end])
  jump_identification!(jump_id, series2; starting_index = k + starting_index, top_level = false)
  return nothing
end

function plot_jumps(series::ZeroMeanSeries, jump_id::JumpIdentifier)
  idx = sort(collect(jump_id.index))
  pl = plot(series.data, legend = false, linestyle = :dash)
  for k in 1:(length(idx)-1)
    i1, i2 = idx[k] + 1, idx[k+1]
    sub_data = series.data[i1:i2]
    avg = sum(sub_data) / length(sub_data)
    plot!(pl, i1:i2, fill(avg, length(i1:i2)), color = :red)
  end
  return pl
end
