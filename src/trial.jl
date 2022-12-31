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
    time_eval::Float64 = 0.0
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
    time_eval::Float64
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
    t = sum(trial.time_eval for trial in trials)
    GroupedTrial(trials,
                 values,
                 value_id,
                 performance,
                 counter,
                 pruned,
                 t)
end

function getobjectives(trial::GroupedTrial)
    f1 = -count_success(trial)
    f2 = trial.performance
    f3 = trial.time_eval
    f1, f2, f3
end

function lexicographic_coparison(Fa::Tuple, Fb::Tuple)
    for (a, b) in zip(Fa, Fb)
        if a < b
            return true
        elseif a > b
            return false
        end
    end
    true
end


function compare(a::Tuple, b::Tuple)
    k = length(a)
    if k != length(b)
        return 3
    end

    i = 1
    while i <= k && a[i] == b[i]
        i += 1
    end

    if i > k
        return 0 # equals
    end

    if a[i] < b[i]
        for j = i+1:k
            if b[j] < a[j]
                return 3 #a and b are incomparable
            end
        end
        return 1 #  a dominates b
    end

    for j = i+1:k
        if a[j] < b[j]
            return 3 # a and b are incomparable
        end
    end

    return 2 # b dominates a
end


function isbetter(ga::GroupedTrial, gb::GroupedTrial)
    lexicographic_coparison(getobjectives(ga), getobjectives(gb))

    #= check successful instances
    if count_success(ga) < count_success(gb)
        return false
    elseif count_success(ga) > count_success(gb)
        return true
    end

    fa = ga.performance
    fb = gb.performance

    # TODO consider multi-objective
    # check via objective values
    if fa > fb
        return false
    elseif fa < fb
        return true
    end

    # check time cost
    if ga.time_eval > ga.time_eval
        return false
    end

    true
    =#
end


function findtradeoffs(Fs)
    mask = [1]
    n = length(Fs)
    for i in 2:n
        j = 1
        while j <= length(mask)
            relation = compare(Fs[i], Fs[mask[j]])
            if relation == 2 # j dominates i
                break
            elseif relation == 1 # i dominates j
                deleteat!(mask, j)
                continue
            end
            j += 1
        end
        if j > length(mask)
            push!(mask, i)
        end
    end
    return mask
end

function Base.show(io::IO, trial::GroupedTrial)
    if isempty(trial.trials)
        println(io, "GroupedTrial - Empty")
        return
    end

    h = (["Trial", "Value"], [trial.id, ""])

    _trial = first(trial.trials)
    ks = sort(keys(_trial.values) |> collect)
    v = [_trial.values[k] for k in ks]
    parameters = Any[ks v]
    data = parameters

    if length(trial.trials) == 1
        data = vcat(
                    data,
                    ["Pruned"  _trial.pruned],
                    ["Success" _trial.success],
                    ["Objective" _trial.fval],
                   )
    else
        data = vcat(data, Any["Instance" ""])
        vals = [t.fval for t in trial.trials]
        labs = [t.instance for t in trial.trials]
        # success = [t.success for t in trial.trials]
        # pruned = [t.pruned for t in trial.trials]

        data = vcat(data, Any[labs vals])
    end

    PrettyTables.pretty_table(io, data, header=h)
end

function trials_to_table(io, trials::Array{<:GroupedTrial})
    if isempty(trials)
        return PrettyTables.pretty_table(io, zeros(0,0))
    end

    ks = collect(keys(first(trials).trials[1].values)) |> collect |> sort
    parameters = Any[t.trials[1].values[k] for t in trials, k in ks]
    ids = [t.id for t in trials]
    nsuccess = [t.count_success for t in trials]
    pruned = [t.pruned for t in trials]
    obj = length(first(trials).trials) > 1 ? "Mean" : "Objective"
    ttime = [t.time_eval for t in trials] 

    means = [t.performance for t in trials]
    data = hcat(ids, parameters, nsuccess, means, ttime, pruned)
    h = vcat("ID", ks, "Success", obj, "Time", "Pruned")

    mask = sortperm(trials, lt = isbetter)
    data = data[mask, :]

    PrettyTables.pretty_table(io, data, header=h)
end


function Base.show(io::IO, m::MIME"text/plain", trials::Array{<:GroupedTrial})
    if length(trials) == 1
        return Base.show(io, m, first(trials))
    end
    
    println(io, "PARAMETERS:")
    trials_to_table(io, trials)
end

function best_parameters(scenario)
    return scenario.best_trial
end

function top_parameters(scenario; ignore_pruned=true)
    if ignore_pruned
        hs = [trial for trial in history(scenario) if !trial.pruned]
    else
        hs = history(scenario)
    end

    if isempty(hs)
        return GroupedTrial[]
    end

    mask = getobjectives.(hs) |> findtradeoffs
    hs[mask]
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
    stop_reason::AbstractStop = NotOptimized()
end

history(status::StatusParami) = status.history

function get_convergence(status::StatusParami, only_performance=true)
    hs = history(status)
    best = hs[1]
    [
     begin
         best = best.performance >= h.performance ? h : best
         only_performance ? (step, best.performance) : (step, best)
     end
     for (step, h) in enumerate(hs) if best.performance > h.performance
    ]
end

function trial_performance(trial::AbstractVector{<:Trial})
    if isempty(trial)
        return Inf
    end

    if length(trial) == 1
        return first(get_fvals(trial)) 
    end

    # TODO improve this
    return sts.mean(get_fvals(trial))
    
    # TODO improve this
    # v1 = length(trial) - count_success(trial)
    # v2 = sum(get_fvals(trial))

    # 100v1*(1 + abs(v2)) + v2
end

function trial_performance(trial::GroupedTrial)
    trial.performance
end

count_success(trials::Vector{<:Trial}) = count(t.success for t in trials)
count_success(trial::GroupedTrial) = count_success(trial.trials)
allsucceeded(grouped::GroupedTrial) = length(grouped.trials) > 0 && count_success(grouped) == length(grouped.trials)

function Base.show(io::IO, trial::Trial)
    if trial.pruned
        step = length(trial.record)
        printstyled(io, "[-] Trial ", trial.value_id, " pruned in step ", step," at instance ", trial.instance_id, "\n", color=:light_black)
    else

        c = trial.success ? :green : :default
        m = trial.success ? "[*]" : "[+]"
        printstyled(io, m, " Trial ", trial.value_id, " evaluated ", trial.fval, " at instance ", trial.instance_id, "\n", color = c)
    end
end

function print_trial(trial::Trial)
    p = collect(trial.values)
    sort!(p, by=first)
    if trial.pruned
        step = length(trial.record)
        printstyled("[-] Trial ", trial.value_id,": ", p, " pruned in step ", step," at instance ", trial.instance_id, "\n", color=:light_black)
    else
        c = trial.success ? :green : :default
        m = trial.success ? "[*]" : "[+]"
        printstyled(m, " Trial ", trial.value_id, ": ", p, " evaluated ", trial.fval, " at instance ", trial.instance_id, "\n", color = c)
    end
end

