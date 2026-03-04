import HypothesisTests: SignedRankTest, pvalue

"""
    WilcoxonPruner(; p_value=0.05, start_after=11)

A pruner that uses the Wilcoxon signed-rank test to determine if a trial 
should be pruned. It compares the current trial's values with the best trial's 
values and prunes if the pruner is confident (up to the given p-value) that 
the current trial is worse.

- `p_value`: p-value threshold for pruning (default 0.05). Lower values require 
  stronger evidence to prune.
- `start_after`: Start pruning after this number of completed trials (default 11).

This pruner is effective for optimizing mean/median performance over multiple 
problem instances. It handles different instances across trials by matching 
instance IDs.

# Example
```julia
pruner = WilcoxonPruner(p_value=0.05, start_after=11)
```
"""
mutable struct WilcoxonPruner <: AbstractPruner
    p_value::Float64
    start_after::Int
    values::Dict{Int, Dict{Int, Vector{Float64}}}
    best_trial_id::Union{Int, Nothing}
    started::Bool
end

function WilcoxonPruner(; p_value::Float64 = 0.05, start_after::Int = 11)
    WilcoxonPruner(
        p_value,
        start_after,
        Dict{Int, Dict{Int, Vector{Float64}}}(),
        nothing,
        false
    )
end

function _update_values!(pruner::WilcoxonPruner, history)
    for grouped in history
        for trial in grouped.trials
            instance_id = trial.instance_id
            record = trial.record
            
            if !haskey(pruner.values, instance_id)
                pruner.values[instance_id] = Dict{Int, Vector{Float64}}()
            end
            
            for (step, val) in enumerate(record)
                if !haskey(pruner.values[instance_id], step)
                    pruner.values[instance_id][step] = Float64[]
                end
                push!(pruner.values[instance_id][step], val)
            end
        end
    end
end

function _find_best_trial(history)
    best_perf = Inf
    best_id = nothing
    
    for (idx, grouped) in enumerate(history)
        if grouped.performance < best_perf
            best_perf = grouped.performance
            best_id = idx
        end
    end
    
    return best_id
end

function update_pruner!(pruner::WilcoxonPruner, history, n_instances::Int)
    if length(history) < pruner.start_after
        return
    end
    
    _update_values!(pruner, history)
    pruner.best_trial_id = _find_best_trial(history)
    pruner.started = true
end

function _get_matching_values(pruner::WilcoxonPruner, current_trial, best_trial)
    current_record = current_trial.record
    best_record = best_trial.record
    
    current_vals = Float64[]
    best_vals = Float64[]
    
    current_instance = current_trial.instance_id
    
    if haskey(pruner.values, current_instance)
        for step in 1:min(length(current_record), length(best_record))
            if haskey(pruner.values[current_instance], step)
                all_vals = pruner.values[current_instance][step]
                if length(all_vals) >= 2
                    push!(current_vals, current_record[step])
                    push!(best_vals, all_vals[end])
                end
            end
        end
    end
    
    return current_vals, best_vals
end

function should_prune(pruner::WilcoxonPruner, step::Int, instance_id::Int, val)
    if !pruner.started || pruner.best_trial_id === nothing
        return false
    end
    
    current_vals = Float64[val]
    best_vals = Float64[]
    
    if haskey(pruner.values, instance_id) && haskey(pruner.values[instance_id], step)
        all_vals = pruner.values[instance_id][step]
        if !isempty(all_vals)
            push!(best_vals, all_vals[end])
        end
    end
    
    if length(current_vals) < 2 || length(best_vals) < 2
        return false
    end
    
    try
        test = SignedRankTest(best_vals, current_vals)
        p = pvalue(test)
        
        if p < pruner.p_value
            current_avg = sts.mean(current_vals)
            best_avg = sts.mean(best_vals)
            return current_avg >= best_avg
        end
        return false
    catch
        return false
    end
end
