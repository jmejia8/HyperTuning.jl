Base.@kwdef mutable struct Trial{I}
    values::Dict = Dict()
    value_id::Int = 1
    fval::Union{Float64, Vector{Float64}} = Inf
    instance::I = 0
    instance_id::Int = 0
    seed::Int = 1
    record::Vector = []
    pruned::Bool = false
end

get_instance(trial::Trial) = trial.instance
get_seed(trial::Trial) = trial.seed


"""
    GroupedTrial

Trials grouped per instance.
"""
struct GroupedTrial
    trials::Vector{Trial}
    id::Int
end

function group_trials_by_instance(trials::Vector{<:Trial}, instances)
    if length(instances) <= 1
        return [GroupedTrial([trial], 1) for trial in trials]
    end
    trials = copy(trials)
    
    grouped_trials = GroupedTrial[]
    value_id = unique([t.value_id for t in trials])

    for i in value_id
        indices = findall(t -> t.value_id==i, trials)
        if isempty(indices)
            continue
        end
        push!(grouped_trials, GroupedTrial(trials[indices], i))
        deleteat!(trials, indices)

    end
    grouped_trials
end

function get_fvals(trial::GroupedTrial)
    [t.fval for t in trial.trials]
end


Base.@kwdef mutable struct StatusParami
    history::Vector{GroupedTrial} = GroupedTrial[]
    f_evals::Int = 0
    start_time::Float64 = time()
end

function trial_performance(trial::GroupedTrial)
    if isempty(trial.trials)
        return Inf
    end
    
    # TODO improve this
    sum(get_fvals(trial))
end

