# use AtRandom from SearchSpaces
struct RandomSampler{R} <: AbstractSampler
    rng::R
end

function RandomSampler(;seed = 11497110100111109,rng = default_rng_parami(seed))
    RandomSampler(rng)
end

Sampler(s::RandomSampler, parameters::MixedSpace) = AtRandom(parameters, rng=s.rng)

