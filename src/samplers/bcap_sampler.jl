export BCAPSampler

"""
    BCAPSampler(searchspace;rng)

Define a random iterator for the search space.
"""
mutable struct BCAPSampler{R} <: AbstractRNGSampler
    rng::R
    population::Array
    mass::Vector{Float64}
    population_size::Int
    n_evaluated::Int
end

BCAPSampler() = BCAPSampler(Random.default_rng(), [], zeros(0), 0, 0)

function _init_BCAPSampler!(bcap, searchspace, rng)
    display(searchspace)
    _n = SearchSpaces.getdim(searchspace)
    # TODO: is 100 the best upper bound?
    N = clamp(round(Int, sqrt(_n)*_n), 10, 100)

    # random initialization
    bcap.population = rand(rng, searchspace, N)
    bcap.mass = ones(N)
    bcap.population_size = N

    bcap
    #BCAPSampler(rng, population, mass, N, 0)
end

#=
function BCAPSampler(searchspace::AtomicSearchSpace; rng=Random.default_rng())
    _init_BCAPSampler!(BCAPSampler(), searchspace, rng)
end
=#


function BCAPSampler(searchspace::MixedSpace; rng=Random.default_rng())
    ss = Dict(k => Sampler(BCAPSampler(), searchspace.domain[k]) for k in keys(searchspace.domain))
    Sampler(ss, searchspace, cardinality(searchspace))
end

function BCAPSampler(searchspace::AbstractSearchSpace; rng=Random.default_rng())
    Sampler(BCAPSampler(), searchspace)
end

function _center_worst(population, mass, rng)
    mask = rand(rng, eachindex(population), 3)
    m = mass[mask]
    m /= sum(m)
    sum(population[mask] .* m), population[argmin(m)]
end

function _fix_to_center!(x, c, bounds::Bounds)
    mask = bounds.lb .> x .|| x .> bounds.ub
    x[mask] = c[mask]
    x
end

function _bcap_candidate_real(population, mass, bounds, rng)
    c, w = _center_worst(population, mass, rng)
    x = rand(rng, population) + 2rand(rng)*(c - w)
    _fix_to_center!(x, c, bounds)
end

function _bcap_candidate(population, mass, bounds::Bounds, rng)
    _bcap_candidate_real(population, mass, bounds, rng)
end

function _bcap_candidate(population, mass, bounds::Bounds{T}, rng) where T <: Integer
    x = _bcap_candidate_real(population, mass, bounds, rng)
    round.(T, x)
end

function SearchSpaces.value(sampler::Sampler{S, B}) where {S<:BCAPSampler,B<:Bounds}
    bcap = sampler.method
    
    if isempty(bcap.population)
        _init_BCAPSampler!(bcap, sampler.searchspace, bcap.rng)
    end

    population = bcap.population

    # check whether current population is evaluated
    if bcap.n_evaluated < bcap.population_size
        bcap.n_evaluated += 1
        return population[bcap.n_evaluated]
    end

    _bcap_candidate(population, bcap.mass, sampler.searchspace, bcap.rng)
end

#=
function value(sampler::Sampler{R, P}) where {R<:BCAPSampler,P<:BitArrays}
end

function value(sampler::Sampler{R, P}) where {R<:BCAPSampler, P<:Permutations}
end
=#
