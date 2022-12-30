abstract type AbstractStop end

struct NotOptimized <: AbstractStop end
struct AllInstancesSucceeded <: AbstractStop end

Base.@kwdef struct NoMoreTrials <: AbstractStop
    msg::String = "Sampler refuses to suggest trials"
end

Base.@kwdef struct BudgetExceeded <: AbstractStop
    msg::String = "max_trials or max_evals or max_time exceeded"
end

