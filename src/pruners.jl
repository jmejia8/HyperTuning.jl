abstract type AbstractPruner end

struct NeverPrune <: AbstractPruner end

update_pruner!(pruner::NeverPrune, history, n_instances::Int) = nothing
should_prune(pruner::NeverPrune, step::Int, instance_id::Int, val) = false

"""
    MedianPruner(;start_after, prune_after)

- start_after: Start up pruner after this number (of completed trials).
- prune_after: Prune a trial after this value (considering the median criteria).
- median_vals: median values reported for each instance.
"""
mutable struct MedianPruner <: AbstractPruner
    start_after::Int
    prune_after::Int
    median_vals::Matrix{Float64}
    started::Bool
end


function MedianPruner(start_after = 11, prune_after = 10)
    MedianPruner(start_after, prune_after, zeros(0, 0), false)
end


function update_pruner!(pruner::MedianPruner, history, n_instances::Int)
    if length(history) < pruner.start_after
        # not enough history to start pruning
        return
    end
    
    trials = [trial for trial in history if !trial.pruned]
    if isempty(trials) || isempty(first(history).trials)
        return
    end

    n_record = first(first(history).trials).record |> length

    if n_record == 0
        return
    end
    

    data = zeros(length(trials), n_instances, n_record)
    for (i, grouped) in enumerate(trials)
        for trial in grouped.trials
            for (k, r) in enumerate(trial.record)
                data[i, trial.instance_id, k] = r
            end
        end
    end

    pruner.median_vals = sts.median(data, dims=1)[1,:,:]
    pruner.started = true;
end

function should_prune(pruner::MedianPruner, step::Int, instance_id::Int, val)
    if !pruner.started || step < pruner.prune_after
        return false
    end
    
    val > pruner.median_vals[instance_id, step]
end

