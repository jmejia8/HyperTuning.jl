"""
parameters(hyperparameters...)

Define hyperparameters.
"""
function parameters(ps::Pair...)
    MixedSpace(ps...)
end

