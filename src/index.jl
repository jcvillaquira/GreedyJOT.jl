# Wrapper for index findex
function argmax_index(series::ZeroMeanSeries; lambda::Float64 = 0.0, simple::Bool = true)
  if simple
    return simple_argmax_index(series; lambda = lambda)
  end
  return fancy_argmax_index(series; lambda = lambda)
end

# Finds index where dual TV is maximized
function simple_argmax_index(series::ZeroMeanSeries; lambda::Float64 = 0.0)
  max_dual_tv, sk, idx = -Inf, 0.0, 0
  for k in eachindex(series.data)
    sk += series.data[k]
    if abs(sk) > max_dual_tv
      max_dual_tv = abs(sk)
      idx = k
    end
  end
  if max_dual_tv > lambda / 2
    return idx
  end
  return nothing
end

# Find optimal index with formula
function fancy_argmax_index(series::ZeroMeanSeries; lambda::Float64 = 0.0)
  max_dual_tv, sk, idx = -Inf, 0.0, 0
  for k in 1:(length(series.data) - 1)
    nk = length(series.data) - k
    sk += series.data[k]
    param = max(abs(sk) - lambda / 2, 0.0) ^ 2
    param /= ( k * nk / length(series.data) )
    println(param)
    if param > max_dual_tv
      max_dual_tv = param
      idx = k
    end
  end
  if max_dual_tv > 0
    return idx
  end
  return nothing
end
