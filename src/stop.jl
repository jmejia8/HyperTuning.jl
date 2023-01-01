abstract type AbstractStop end

struct NotOptimized <: AbstractStop end
struct AllInstancesSucceeded <: AbstractStop end

"""
    NoMoreTrials()

Used to inform that ampler refuses to suggest trials.
"""
Base.@kwdef struct NoMoreTrials <: AbstractStop
    msg::String = "Sampler refuses to suggest trials."
end

"""
    BudgetExceeded([msg])

Used to inform if budget has been exceeded.
"""
Base.@kwdef struct BudgetExceeded <: AbstractStop
    msg::String = "max_trials or max_evals or max_time exceeded"
end

