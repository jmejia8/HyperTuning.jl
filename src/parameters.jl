"""
parameters(hyperparameters...)

Define hyperparameters.
"""
function parameters(ps::Pair...)
    MixedSpace(ps...)
end

"""
    ..(a, b)

Define a interval between a and b (inclusive).

See also [`Bounds`](@ref)
"""
..(a::Real, b::Real) = Bounds(a, b)
..(a::Bool, b::Bool) = BitArrays(1)
