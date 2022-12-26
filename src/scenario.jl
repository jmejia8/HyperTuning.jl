import Random
abstract type AbstractScenario end
abstract type AbstractPruner end

struct MedianPruner <: AbstractPruner
    start_after::Int
end

function MedianPruner(;start_after = 11)
    MedianPruner(start_after)
end


struct Budget
    max_trials::Int
    max_time::Float32
end

mutable struct Scenario <: AbstractScenario
    parameters::MixedSpace
    sampler#::AbstractSampler
    pruner::AbstractPruner
    instances::AbstractVector
    budget::Budget
    best_trial::GroupedTrial
    status::StatusParami
end

#=
function Budget(;max_trials = 30, max_time = 30.0)
    Budget(max_trials, max_time)
end
=#

default_sampler() = AtRandom(Random.default_rng())
default_pruner() = MedianPruner()

function Scenario(;
        parameters = MixedSpace(),
        sampler = default_sampler(),
        pruner = default_pruner(),
        instances = [1],
        max_trials = 30,
        max_time = Inf
    )
    _sampler = SearchSpaces.Sampler(sampler, parameters)
    budget = Budget(max_trials, max_time)

    Scenario(parameters,
             _sampler,
             pruner,
             instances,
             budget,
             GroupedTrial(Trial[], 0),
             StatusParami()
            )
end


function save_trials!(_trials::Vector{<:Trial}, scenario::Scenario)
    status = scenario.status

    trials = group_trials_by_instance(_trials, scenario.instances)

    append!(status.history, trials)

    update_best_trial!(scenario, trials)

end

function update_best_trial!(scenario::Scenario, trials::Vector{GroupedTrial})
    @assert !isempty(trials)

    best_trial = argmin(trial_performance, trials)

    # TODO consider multi-objective
    if trial_performance(best_trial) < trial_performance(scenario.best_trial)
        scenario.best_trial = best_trial
    end

    scenario.status.f_evals += length(trials)
end

