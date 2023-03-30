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

See also [`BoxConstrainedSpace`](@ref)
"""
..(a::Real, b::Real) = BoxConstrainedSpace(a, b)
..(a::Bool, b::Bool) = BitArraySpace(1)
