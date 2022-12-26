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
    best_trial::Trial
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
             Trial(),
             StatusParami()
            )
end


function save_trials!(trials::Vector{<:Trial}, scenario::Scenario)
    status = scenario.status
    append!(status.history, trials)
    best_trial = argmin(t -> t.fval, trials)

    # TODO consider multi-objective
    if best_trial.fval < scenario.best_trial.fval
        scenario.best_trial = best_trial
    end

    status.f_evals += length(trials)
end

