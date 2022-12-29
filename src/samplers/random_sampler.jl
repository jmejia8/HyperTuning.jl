# use AtRandom from SearchSpaces
struct RandomSampler{R} <: AbstractSampler
    rng::R
end

function RandomSampler(;rng = default_rng_parami())
    RandomSampler(rng)
end

Sampler(s::RandomSampler, parameters::MixedSpace) = AtRandom(parameters, rng=s.rng)

