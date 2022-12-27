struct NeverPrune <: AbstractPruner end

update_pruner!(pruner::NeverPrune, history, n_instances::Int) = nothing
should_prune(pruner::NeverPrune, step::Int, instance_id::Int, val) = false

