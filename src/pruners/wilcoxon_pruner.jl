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
    best_records::Dict{Int, Vector{Float64}}
    started::Bool
end

function WilcoxonPruner(; p_value::Float64 = 0.05, start_after::Int = 11)
    WilcoxonPruner(
        p_value,
        start_after,
        Dict{Int, Dict{Int, Vector{Float64}}}(),
        nothing,
        Dict{Int, Vector{Float64}}(),
        false
    )
end

"""
    _update_values!(pruner::WilcoxonPruner, history)

Update the internal values dictionary from completed trials in history.

# Arguments
- `pruner::WilcoxonPruner`: The pruner instance to update
- `history`: Vector of `GroupedTrial` objects representing completed trials

# Details
Builds a nested dictionary mapping `(instance_id) -> (step) -> Vector{Float64}`
storing all reported values for each instance and evaluation step. This data
is used for statistical comparison in the Wilcoxon signed-rank test.

# Example
```julia
history = status.history  # Vector of GroupedTrial
_update_values!(pruner, history)
```
"""
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

"""
    _find_best_trial(history) -> Union{Int, Nothing}

Find the trial with the best (lowest) performance in the history.

# Arguments
- `history`: Vector of `GroupedTrial` objects representing completed trials

# Returns
- `Union{Int, Nothing}`: Index of the best trial in history, or `nothing` if empty

# Details
Compares the `performance` field of each `GroupedTrial` and returns the index
of the trial with the lowest (best) performance value.

# Example
```julia
best_idx = _find_best_trial(history)
best_trial = history[best_idx]
```
"""
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

"""
    update_pruner!(pruner::WilcoxonPruner, history, n_instances::Int)

Update the pruner state with completed trials from history.

# Arguments
- `pruner::WilcoxonPruner`: The pruner instance to update
- `history`: Vector of `GroupedTrial` objects representing completed trials
- `n_instances::Int`: Number of problem instances being optimized over

# Returns
- `Nothing`

# Details
This method is called after each trial completion. It:
1. Returns early if fewer than `start_after` trials have completed
2. Updates internal value storage via `_update_values!`
3. Identifies the best trial via `_find_best_trial`
4. Sets `pruner.started = true` to enable pruning decisions

The pruner requires at least `start_after` trials before making pruning decisions
to ensure sufficient data for the Wilcoxon signed-rank test.
"""
function update_pruner!(pruner::WilcoxonPruner, history, n_instances::Int)
    if length(history) < pruner.start_after
        return
    end
    
    _update_values!(pruner, history)
    pruner.best_trial_id = _find_best_trial(history)
    empty!(pruner.best_records)
    if pruner.best_trial_id !== nothing
        best_grouped = history[pruner.best_trial_id]
        for trial in best_grouped.trials
            pruner.best_records[trial.instance_id] = Float64[Float64(val) for val in trial.record]
        end
    end
    pruner.started = true
end

"""
    should_prune(pruner::WilcoxonPruner, trial) -> Bool

Determine whether `trial` should be pruned using the Wilcoxon signed-rank test.

The pruner compares the sequence of values collected so far for the current trial
with the stored record of the best-performing trial on the same instance. Pruning
occurs when the signed-rank test finds the current sequence statistically worse
than the best sequence (p-value below `p_value`) and the current average is not
better than the best average.
"""
function should_prune(pruner::WilcoxonPruner, trial)
    if !pruner.started || pruner.best_trial_id === nothing
        return false
    end

    current_record = trial.record
    if length(current_record) < 2
        return false
    end

    instance_id = trial.instance_id
    best_record = get(pruner.best_records, instance_id, nothing)
    if best_record === nothing
        return false
    end

    limit = min(length(current_record), length(best_record))
    if limit < 2
        return false
    end

    current_vals = Float64[current_record[i] for i in 1:limit]
    best_vals = Float64[best_record[i] for i in 1:limit]

    try
        test = SignedRankTest(best_vals, current_vals)
        p = pvalue(test)

        if p < pruner.p_value
            current_avg = sts.mean(current_vals)
            best_avg = sts.mean(best_vals)
            return current_avg <= best_avg
        end
    catch
        return false
    end

    return false
end
