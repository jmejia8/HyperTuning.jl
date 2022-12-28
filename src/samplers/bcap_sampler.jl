abstract type PopulationBasedSampler <: AbstractRNGSampler end

export BCAPSampler

"""
    BCAPSampler(searchspace;rng)

Define a random iterator for the search space.
"""
mutable struct BCAPSampler{R} <: PopulationBasedSampler
    rng::R
    population::Array
    fitness::Vector{Float64}
    mass::Vector{Float64}
    population_size::Int
end

BCAPSampler() = BCAPSampler(default_rng_parami(), [], zeros(0), zeros(0), 0)

function _init_BCAPSampler!(bcap, searchspace, rng)
    _n = SearchSpaces.getdim(searchspace)
    # TODO: is 200 the best upper bound?
    N = clamp(round(Int, sqrt(_n)*_n), 20, 200)

    bcap.population_size = N
    bcap
end

function BCAPSampler(searchspace::AtomicSearchSpace; rng=default_rng_parami())
    _init_BCAPSampler!(BCAPSampler(), searchspace, rng)
end


function BCAPSampler(searchspace::MixedSpace; rng=default_rng_parami())
    ss = Dict(k => Sampler(BCAPSampler(searchspace.domain[k]; rng), searchspace.domain[k]) for k in keys(searchspace.domain))
    Sampler(ss, searchspace, cardinality(searchspace))
end

function BCAPSampler(searchspace::AtomicSearchSpace; rng=default_rng_parami())
    Sampler(BCAPSampler(), searchspace)
end

function _center_worst(population, mass, rng)
    mask = rand(rng, eachindex(population), 3)
    m = mass[mask]
    m /= sum(m)
    sum(population[mask] .* m), population[argmin(m)]
end

function _fix_candidate!(x, bounds::Bounds)
    mask = x .< bounds.lb
    x[mask] = bounds.lb[mask]
    mask = x .> bounds.ub
    x[mask] = bounds.ub[mask]
    x
end

function _bcap_candidate_real(population, mass, bounds, rng)
    c, w = _center_worst(population, mass, rng)
    x = rand(rng, population) + 1.2rand(rng)*(c - w)
    _fix_candidate!(x, bounds)
end

function _bcap_candidate(population, mass, bounds::Bounds, rng)
    _bcap_candidate_real(population, mass, bounds, rng)
end

function _bcap_candidate(population, mass, bounds::Bounds{T}, rng) where T <: Integer
    x = _bcap_candidate_real(population, mass, bounds, rng)
    round.(T, x)
end


function _bcap_candidate(population, mass, booleans::BitArrays, rng) 
    d = SearchSpaces.getdim(booleans)
    bounds = Bounds(zeros(d), ones(d))
    x = _bcap_candidate_real(population, mass, bounds, rng)
    x .< 0.5
end

function _bcap_candidate(population, mass, searchspace::AtomicSearchSpace, rng)
    rand(rng, searchspace)
end

function SearchSpaces.value(
        sampler::Sampler{S, B}
    ) where {S<:BCAPSampler, B<:Union{Bounds, BitArrays}}
    bcap = sampler.method
    population = bcap.population
    searchspace = sampler.searchspace

    # initialization at random
    if length(population) < bcap.population_size
        return rand(bcap.rng, searchspace)
    end

    v = _bcap_candidate(population, bcap.mass, sampler.searchspace, bcap.rng)
    # TODO improve for numerical samples
    return length(v) == 1 ? first(v) : v
end

function _bca_update_mass!(bcap)
    fitness = bcap.fitness
    M = maximum(abs.(fitness))
    bcap.mass = 2M .- fitness
    bcap
end

function report_values_to_sampler!(
        sampler::Sampler{R, P},
        val_and_fvals::Vector{<:Tuple}
    ) where {R<:BCAPSampler, P <: AbstractSearchSpace}

    bcap = sampler.method

    _pre_proc(v) = v isa Number ? [v] : v

    append!(bcap.population, _pre_proc.(first.(val_and_fvals)))
    append!(bcap.fitness, last.(val_and_fvals))

    # reduce population elements
    population_size = bcap.population_size
    if length(bcap.population) <= population_size
        # nothing to remove
        return
    end
    # delete elements in population
    delete = sortperm(bcap.fitness)[population_size+1:end]
    sort!(delete)
    deleteat!(bcap.population, delete)
    deleteat!(bcap.fitness, delete)

    # update mass values
    _bca_update_mass!(bcap)
end

