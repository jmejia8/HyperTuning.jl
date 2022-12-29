abstract type AbstractScenario end

default_rng_parami(seed=1223334444) = Random.Xoshiro(seed)

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
    status::StatusParami
    verbose::Bool
    batch_size::Int
end


default_sampler() = RandomSampler#(Random.default_rng())
default_pruner() = NeverPrune()

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


function Scenario(;
        parameters = MixedSpace(),
        sampler    = default_sampler(),
        pruner     = default_pruner(),
        instances  = [1],
        max_trials = :auto,
        max_evals  = :auto,
        max_time   = :auto,
        verbose    = false,
        batch_size = max(nprocs(), Sys.CPU_THREADS),
    )
    _sampler = sampler(parameters)

    budget = suggest_budget(max_trials, max_evals, max_time, parameters, instances, _sampler)

    Scenario(parameters,
             _sampler,
             pruner,
             instances,
             budget,
             GroupedTrial(Trial[]),
             StatusParami(),
             verbose,
             batch_size,
            )
end


function save_trials!(ungrouped_trials::Vector{<:Trial}, scenario::Scenario)
    status = scenario.status
    trials = group_trials_by_instance(ungrouped_trials, scenario.instances)
    append!(status.history, trials)
    update_best_trial!(scenario, trials)
    report_values_to_sampler!(scenario.sampler, trials)
end

function update_best_trial!(scenario::Scenario, trials::Vector{GroupedTrial})
    if isempty(trials)
        return
    end

    best_trial = argmin(trial_performance, trials)

    # TODO consider multi-objective
    if trial_performance(best_trial) < trial_performance(scenario.best_trial)
        scenario.best_trial = best_trial
    end

end

