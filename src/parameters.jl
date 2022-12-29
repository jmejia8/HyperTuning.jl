function parameters(ps::Pair...)
    MixedSpace(ps...)
end

..(a::Real, b::Real) = Bounds(a, b)
..(a::Bool, b::Bool) = BitArrays(1)
