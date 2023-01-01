# use AtRandom from SearchSpaces
struct RandomSampler{R} <: AbstractSampler
    rng::R
end

"""
    RandomSampler(;seed, rng)

Define a iterator for the random sampler.
"""
function RandomSampler(;seed = 11497110100111109,rng = default_rng_ht(seed))
    RandomSampler(rng)
end

Sampler(s::RandomSampler, parameters::MixedSpace) = AtRandom(parameters, rng=s.rng)

