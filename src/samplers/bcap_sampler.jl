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

BCAPSampler() = BCAPSampler(Random.default_rng(), [], zeros(0), zeros(0), 0)

function _init_BCAPSampler!(bcap, searchspace, rng)
    _n = SearchSpaces.getdim(searchspace)
    # TODO: is 100 the best upper bound?
    N = clamp(round(Int, sqrt(_n)*_n), 10, 100)

    bcap.population_size = N
    bcap
end

function BCAPSampler(searchspace::AtomicSearchSpace; rng=Random.default_rng())
    _init_BCAPSampler!(BCAPSampler(), searchspace, rng)
end


function BCAPSampler(searchspace::MixedSpace; rng=Random.default_rng())
    ss = Dict(k => Sampler(BCAPSampler(searchspace.domain[k]; rng), searchspace.domain[k]) for k in keys(searchspace.domain))
    Sampler(ss, searchspace, cardinality(searchspace))
end

function BCAPSampler(searchspace::AtomicSearchSpace; rng=Random.default_rng())
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
    population = bcap.population
    searchspace = sampler.searchspace

    # initialization
    if length(population) < bcap.population_size
        return rand(bcap.rng, searchspace)
    end

    _bcap_candidate(population, bcap.mass, sampler.searchspace, bcap.rng)
end

#=
function value(sampler::Sampler{R, P}) where {R<:BCAPSampler,P<:BitArrays}
end

function value(sampler::Sampler{R, P}) where {R<:BCAPSampler, P<:Permutations}
end
=#


function _bca_update_mass!(bcap)
    fitness = bcap.fitness
    M = maximum(abs.(fitness))
    bcap.mass = 2M .- fitness
    bcap
end

function report_values_to_sampler!(
        sampler::Sampler{R, P},
        val_and_fvals::Vector{<:Tuple}
    ) where {R<:BCAPSampler, P <: Bounds}

    bcap = sampler.method

    append!(bcap.population, first.(val_and_fvals))
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
    display(bcap.population)
end

