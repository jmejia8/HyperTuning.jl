abstract type AbstractScenario end

"""
    default_rng_ht(seed)

Default random number generator in HyperTuning.
"""
default_rng_ht(seed=1223334444) = Random.Xoshiro(seed)
default_sampler() = BCAPSampler()
default_pruner() = NeverPrune()

struct Budget
    max_trials::Int
    max_time::Float32
    max_evals::Int
end

mutable struct Scenario <: AbstractScenario
    parameters::MixedSpace
    sampler#::AbstractSampler
    pruner::AbstractPruner
    instances::AbstractVector
    budget::Budget
    best_trial::GroupedTrial
    status::StatusHyperTuning
    verbose::Bool
    batch_size::Int
end

function default_stop_criteria(scenario::Scenario)
    budget_exceeded(scenario) ||
    all_instances_succeeded(scenario)
end

function Base.show(io::IO, scenario::Scenario)
    optimized = isempty(scenario.best_trial.values)

    if optimized
        println(io, "Scenario:")
    else
        println(io, "Scenario: evaluated ", length(history(scenario)) , " trials.")
    end

    c = cardinality(scenario.parameters)
    parameters = collect(scenario.parameters.domain |> keys .|> string) |> sort

    @printf(io, "% 20s: ", "parameters")
    println(io, join(parameters, ", "))
    @printf(io, "% 20s: ", "space cardinality")
    println(io, isfinite(c) && c < typemax(Int) ? c : "Huge!")
    @printf(io, "% 20s: ", "instances")
    println(io, length(scenario.instances) == 1 ? first(scenario.instances) : scenario.instances)
    @printf(io, "% 20s: %d\n", "batch_size", scenario.batch_size)
    @printf(io, "% 20s: ", "sampler")
    if scenario.sampler.method isa Dict
        println(io, string(typeof(last(first(scenario.sampler.method)).method)))
    else
        println(io, string(typeof(scenario.sampler.method)))
    end
    
    @printf(io, "% 20s: ", "pruner")
    println(io, string(typeof(scenario.pruner)))
    @printf(io, "% 20s: %d\n", "max_trials", scenario.budget.max_trials)
    @printf(io, "% 20s: %d\n", "max_evals", scenario.budget.max_evals)

    if scenario.status.stop_reason != NotOptimized()
        @printf(io, "% 20s: ", "stop_reason")
        println(io, scenario.status.stop_reason)
    end

    if !optimized
        @printf(io, "% 20s: \n", "best_trial")
        show(io, scenario.best_trial)
    end
end

"""
    Scenario(;
            parameters...,
            sampler    = default_sampler(),
            pruner     = default_pruner(),
            instances  = [1],
            max_trials = :auto,
            max_evals  = :auto,
            max_time   = :auto,
            verbose    = false,
            batch_size = max(nprocs(), Sys.CPU_THREADS),
        )

Define an Scenario with parameters, and budget.


- `sampler` sampler to be used.
- `pruner` pruner to reduce computational cost.
- `instances` array (iterator) containing the problem instances.
- `max_trials` maximum number of trials to be evaluated on [`optimize`](@ref).
- `max_evals` maximum number of function evaluations.
- `max_time` maximum execution time on [`optimize`](@ref).
- `verbose` show message during the optimization.
- `batch_size` number of trials evaluated for each instance for each iteration.
"""
function Scenario(;
        parameters = nothing,
        sampler    = default_sampler(),
        pruner     = default_pruner(),
        instances  = [1],
        max_trials = :auto,
        max_evals  = :auto,
        max_time   = :auto,
        verbose    = false,
        batch_size = max(nprocs(), Sys.CPU_THREADS),
        kargs...
    )
    if !(parameters isa MixedSpace) 
        # TODO update this for empty scenarios
        isempty(kargs) && error("Provide parameters.")
        _params = (k => kargs[k] for k in keys(kargs))
        parameters = MixedSpace(_params...)
    end
    
    _sampler = Sampler(sampler, parameters)

    budget = suggest_budget(max_trials, max_evals, max_time, parameters, instances, _sampler)

    Scenario(parameters,
             _sampler,
             pruner,
             instances,
             budget,
             GroupedTrial(Trial[]),
             StatusHyperTuning(),
             verbose,
             batch_size,
            )
end

"""
    save_trials!(ungrouped_trials, scenario)

Save evaluated trials into scenario history, then update best trial found so far.
Also, report values to the sampler.
"""
function save_trials!(ungrouped_trials::Vector{<:Trial}, scenario::Scenario)
    status = scenario.status
    trials = group_trials_by_instance(ungrouped_trials, scenario.instances)
    append!(status.history, trials)
    update_best_trial!(scenario, trials)
    report_values_to_sampler!(scenario.sampler, trials)
end

"""
    update_best_trial!(scenario, trials)

Update best trial found so far.
"""
function update_best_trial!(scenario::Scenario, trials::Vector{GroupedTrial})
    if isempty(trials)
        return scenario
    end

    for trial in trials
        if isbetter(scenario.best_trial, trial)
            continue
        end
        scenario.best_trial = trial
    end

    scenario
end


"""
    history(scenario)

Return all evaluated trails.
"""
history(scenario::Scenario) = history(scenario.status)

"""
    get_convergence(scenario)

Return vector of tuples containing the trial id and objective value.
"""
get_convergence(scenario::Scenario) = get_convergence(scenario.status)
allsucceeded(scenario::Scenario) = allsucceeded(scenario.best_trial)
get_best_values(scenario::Scenario) = best_parameters(scenario).values
UnPack.unpack(scenario::Scenario, ::Val{k}) where {k} = get_best_values(scenario)[k]

function export_history(scenario::Scenario)
    # TODO
end


function suggest_budget(max_trials, max_evals, max_time, parameters, instances, sampler)
    max_time = max_time isa Symbol ? Inf : max_time

    if max_trials === :auto
        card = n_parameters = SearchSpaces.getdim(parameters)
        try 
            card = cardinality(parameters) |> Int
        catch InexactError
            card = 20n_parameters
        end

        max_trials = min(card, 1000)
    end

    if max_evals ===  :auto
        max_evals = max_trials*length(instances)
    end

    Budget(max_trials, max_time, max_evals)
end
