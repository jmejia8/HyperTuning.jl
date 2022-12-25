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

mutable struct Experiment{I}
    trail::Dict # provided by the sampler after evaluation
    record::Vector # optionally provided by user in objective function
    instance::I # given by the optimizer
    job_id::Int # for parallel evaluations
end

mutable struct Scenario <: AbstractScenario
    parameters::MixedSpace
    sampler#::AbstractSampler
    pruner::AbstractPruner
    instances::AbstractVector
    budget::Budget
    status::StatusParami
    experiments::Vector{Experiment}
    samplers_info::Dict
end

#=
function Budget(;max_trials = 30, max_time = 30.0)
    Budget(max_trials, max_time)
end
=#

default_sampler() = AtRandom(Random.default_rng())
default_pruner() = MedianPruner()

default_history_len(dim) = clamp(round(Int, sqrt(dim)*dim), 10, 100)

function Scenario(;
        parameters = MixedSpace(),
        sampler = default_sampler(),
        pruner = default_pruner(),
        instances = [1],
        max_trials = 30,
        max_time = Inf,
        history_max_len = :auto
    )

    if history_max_len === :auto
        h_len = 0 # default_history_len(SearchSpaces.getdim(parameters))
    else
        h_len = history_max_len
    end
    
    budget = Budget(max_trials, max_time)
    status = StatusParami(;history_max_len = h_len)
    Scenario(parameters, sampler, pruner, instances, budget, status, Dict())
end

function get_suggested_budget(scenario::Scenario)
    # costs
    all_trials = cardinality(scenario.parameters)
    n_instances = length(scenario.instances)

    # budget
    # budget = scenario.budget
    # max_trials  = scenario.budget.max_trials
    # max_time = scenario.budget.max_time

    max_trials = min(n_instances*all_trials, 1000*n_instances, 1000) |> Int

    if all_trials <= max_trials
        sampler = Grid
    elseif max_trials <= n_instances
        sampler = AtRandom
    else
        sampler = AtRandom
    end
    

    Dict(
         :max_trials => max_trials,
         :sampler => sampler
        )

end

function suggest_budget(scenario)
    println(":::::::::::::::::::::::::::::::::::")
    println("::::   S U G G E S T I N G   ::::::")
    println("::::       B U D G E T       ::::::")
    println(":::::::::::::::::::::::::::::::::::")

    suggestions = get_suggested_budget(scenario)
    display(suggestions)

    #=
    # compute costs vs budget
    println("Instace calls:", max_trials ÷ n_instances, " times.")

    if isfinite(max_time)
        t = round(max_time ÷ n_instances, digits=2)
        println("Desired time:",  t, " seconds.")
    end
    =#
    
end


