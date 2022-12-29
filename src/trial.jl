Base.@kwdef mutable struct Trial{I}
    values::Dict = Dict()
    value_id::Int = 1
    fval::Union{Float64, Vector{Float64}} = Inf
    instance::I = 0
    instance_id::Int = 0
    seed::Int = 1
    record::Vector = []
    pruned::Bool = false
    success::Bool = false
    _pruner::AbstractPruner = NeverPrune()
end

get_instance(trial::Trial) = trial.instance
get_seed(trial::Trial) = trial.seed
report_success!(trial::Trial) = (trial.success = true)
report_value!(trial::Trial, val) = push!(trial.record, val)

function should_prune(trial::Trial)
    step = length(trial.record)
    if step == 0
        return false
    end

    val = last(trial.record)
    instance_id = trial.instance_id

    pruned = should_prune(trial._pruner, step, instance_id, val)
    trial.pruned = pruned
    pruned
end

"""
    GroupedTrial

Trials grouped per instance.
"""
struct GroupedTrial
    trials::Vector{Trial}
    values::Dict
    id::Int
    performance::Float64
    count_success::Int
    pruned::Bool
end

function GroupedTrial(trials::Vector{T}) where T <: Trial
    if isempty(trials)
        return GroupedTrial([Trial()])
    end
    performance = trial_performance(trials)
    counter = count_success(trials)
    pruned  = any(t.pruned for t in trials)
    values = first(trials).values
    value_id = first(trials).value_id
    GroupedTrial(trials, values, value_id, performance, counter, pruned)
end

function Base.show(io::IO, trial::GroupedTrial)
    if isempty(trial.trials)
        println(io, "GroupedTrial - Empty")
        return
    end
    labs = "Instance " .* string.([t.instance_id for t in trial.trials])
    vals = [t.fval for t in trial.trials]

    println(io, "::::::::::::::::::::::::::::::::::::::::::::::")
    println(io, ":::::::::::: P A R A M E T E R S :::::::::::::")
    println(io, "::::::::::::::::::::::::::::::::::::::::::::::")
    for v in first(trial.trials).values
        print(io, first(v), " = ", last(v), ";  ")
    end
    println(io, "")
    plt = UnicodePlots.barplot(labs, vals, title="Instances")
    show(io, plt)
    println(io, "")
    println(io, "::::::::::::::::::::::::::::::::::::::::::::::")
    
    
    

end

function trials_to_table(io, trials::Array{<:GroupedTrial})
    if isempty(trials)
        return PrettyTables.pretty_table(io, zeros(0,0))
    end

    ks = collect(keys(first(trials).trials[1].values))
    parameters = Any[t.trials[1].values[k] for t in trials, k in ks]
    ids = [t.id for t in trials]
    counter = [t.count_success for t in trials]
    pruned = [t.pruned for t in trials]

    stats = [t.performance for t in trials]
    data = hcat(ids, parameters, stats, counter, pruned)
    h = vcat("ID", ks, "Performance", "Success", "Pruned")

    mask = sortperm(stats)
    data = data[mask, :]

    PrettyTables.pretty_table(io, data, header=h)
end


function Base.show(io::IO, ::MIME"text/plain", trials::Array{<:GroupedTrial})
    println(io, "PARAMETERS:")
    trials_to_table(io, trials)
    #=

    if isempty(trials)
        println(io, "GroupedTrials - Empty")
        return
    end
    labs = "Trial " .* string.([t.id for t in trials])
    vals = [t.performance for t in trials]

    mask = sortperm(vals)
    plt = UnicodePlots.barplot(labs[mask], vals[mask], title="Trials Performance")
    show(io, plt)
    println("")
    =#
    
end

function best_parameters(scenario)
    return scenario.best_trial
end

function top_parameters(scenario)
    if isempty(scenario.status.history)
        return GroupedTrial[]
    end
    
    trials = sort(scenario.status.history, by = t -> t.performance)
    v = first(trials).performance
    ts = GroupedTrial[]
    for trial in trials
        if trial.performance != v
            break
        end
        push!(ts, trial)
    end
    ts
end


function group_trials_by_instance(trials::Vector{<:Trial}, instances)
    if length(instances) <= 1
        return [GroupedTrial([trial]) for trial in trials]
    end
    trials = copy(trials)
    
    grouped_trials = GroupedTrial[]
    value_id = unique([t.value_id for t in trials])

    for i in value_id
        indices = findall(t -> t.value_id==i, trials)
        if isempty(indices)
            continue
        end
        push!(grouped_trials, GroupedTrial(trials[indices]))
        deleteat!(trials, indices)

    end
    grouped_trials
end

function get_fvals(trials::AbstractVector{<:Trial})
    [t.fval for t in trials]
end

function get_fvals(trial::GroupedTrial)
    get_fvals(trial.trials)
end

Base.@kwdef mutable struct StatusParami
    history::Vector{GroupedTrial} = GroupedTrial[]
    f_evals::Int = 0
    n_trials::Int = 0
    start_time::Float64 = time()
    stop::Bool = false
end

function trial_performance(trial::AbstractVector{<:Trial})
    if isempty(trial)
        return Inf
    end

    if length(trial) == 1
        return first(get_fvals(trial)) 
    end
    
    
    # TODO improve this
    v1 = length(trial) - count_success(trial)
    v2 = sum(get_fvals(trial))

    100v1*(1 + abs(v2)) + v2
end

function trial_performance(trial::GroupedTrial)
    trial.performance
end

count_success(trials::Vector{<:Trial}) = count(t.success for t in trials)
count_success(trial::GroupedTrial) = count_success(trial.trials)

function print_trial(trial::Trial)
    if trial.pruned
        step = length(trial.record)
        printstyled("[-] Trial ", trial.value_id, " pruned in step ", step," at instance ", trial.instance_id, "\n", color=:light_black)
    else

        c = trial.success ? :green : :default
        m = trial.success ? "[*]" : "[+]"
        printstyled(m, " Trial ", trial.value_id, " evaluated ", trial.fval, " at instance ", trial.instance_id, "\n", color = c)
    end
end

