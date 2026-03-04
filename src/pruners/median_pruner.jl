"""
    MedianPruner(;start_after, prune_after)

- start_after: Start up pruner after this number (of completed trials).
- prune_after: Prune a trial after this value (considering the median criteria).
- median_vals: dictionary mapping (instance_id, step) -> median value
"""
mutable struct MedianPruner <: AbstractPruner
    start_after::Int
    prune_after::Int
    values::Dict{Int, Dict{Int, Vector{Float64}}}
    medians::Dict{Int, Dict{Int, Float64}}
    started::Bool
end


function MedianPruner(;start_after = 11, prune_after = 10)
    MedianPruner(start_after, prune_after, Dict{Int, Dict{Int, Vector{Float64}}}(), Dict{Int, Dict{Int, Float64}}(), false)
end

function _update_medians!(pruner::MedianPruner)
    for (instance_id, steps_dict) in pruner.values
        pruner.medians[instance_id] = Dict{Int, Float64}()
        for (step, values) in steps_dict
            if length(values) >= 2
                pruner.medians[instance_id][step] = sts.median(values)
            end
        end
    end
end


function update_pruner!(pruner::MedianPruner, history, n_instances::Int)
    if length(history) < pruner.start_after
        return
    end
    
    trials = [trial for trial in history if !trial.pruned]
    if isempty(trials) || isempty(first(history).trials)
        return
    end

    for grouped in trials
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

    _update_medians!(pruner)
    pruner.started = true
end

function should_prune(pruner::MedianPruner, step::Int, instance_id::Int, val)
    if !pruner.started ||
        step < pruner.prune_after ||
        !haskey(pruner.medians, instance_id) ||
        !haskey(pruner.medians[instance_id], step)
        return false
    end
    
    val > pruner.medians[instance_id][step]
end

