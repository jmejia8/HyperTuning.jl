abstract type PopulationBasedSampler <: AbstractRNGSampler end


mutable struct BCAPSampler{R} <: PopulationBasedSampler
    rng::R
    population::Array
    fitness::Vector{Float64}
    mass::Vector{Float64}
    population_size::Int
end

"""
    BCAPSampler(searchspace;rng)

Define a iterator for the BCAP sampler.
"""
BCAPSampler(;seed = 989997112, rng=default_rng_ht(seed), population_size=0) = BCAPSampler(rng, [], zeros(0), zeros(0), population_size)

function Sampler(s::BCAPSampler, parameters::MixedSpace)
    BCAPSampler(parameters;rng=s.rng, population_size=s.population_size)
end

function _init_BCAPSampler!(bcap, searchspace, rng)
    _n = SearchSpaces.getdim(searchspace)
    # TODO: is 200 the best upper bound?
    N = clamp(round(Int, sqrt(_n)*_n), 10, 200)

    bcap.population_size = N
    bcap
end

function BCAPSampler(
        searchspace::AtomicSearchSpace;
        seed = 989997112,
        rng=default_rng_ht(seed),
        population_size = 0,
    )
    _init_BCAPSampler!(BCAPSampler(;rng, population_size), searchspace, rng)
end


function BCAPSampler(searchspace::MixedSpace;
        seed = 989997112,
        rng=default_rng_ht(seed),
        population_size = 0,
    )
    ss = Dict(k => Sampler(BCAPSampler(searchspace.domain[k]; rng, population_size), searchspace.domain[k]) for k in keys(searchspace.domain))
    Sampler(ss, searchspace, cardinality(searchspace))
end

function _center_worst(population, mass, rng)
    mask = rand(rng, eachindex(population), 3)
    m = mass[mask]
    m /= sum(m)
    sum(population[mask] .* m), population[argmin(m)]
end

function _fix_candidate!(x, bounds::BoxConstrainedSpace)
    mask = x .< bounds.lb
    x[mask] = bounds.lb[mask]
    mask = x .> bounds.ub
    x[mask] = bounds.ub[mask]
    x
end

function _mut_candidate!(x, bounds, rng)
    η = 15
    # polynomial mutation
    D = length(x)
    mask = rand(rng, D) .< min(0.1, 1/D)
    for i in findall(mask)
        r = rand(rng)
        if r < 0.5
            σ = (2r)^(1/(η + 1)) - 1
        else
            σ = 1 - (2 - 2r)^(1/(η + 1))
        end
        x[i] = x[i] + σ * bounds.Δ[i]
    end
    x
end

function _bcap_candidate_real(population, mass, bounds, rng)
    c, w = _center_worst(population, mass, rng)
    x = rand(rng, population) + 1.2rand(rng)*(c - w)
    _mut_candidate!(x, bounds, rng)
    _fix_candidate!(x, bounds)
end

function _bcap_candidate(population, mass, bounds::BoxConstrainedSpace, rng)
    _bcap_candidate_real(population, mass, bounds, rng)
end

function _bcap_candidate(population, mass, bounds::BoxConstrainedSpace{T}, rng) where T <: Integer
    x = _bcap_candidate_real(population, mass, bounds, rng)
    round.(T, x)
end


function _bcap_candidate(population, mass, booleans::BitArraySpace, rng) 
    d = SearchSpaces.getdim(booleans)
    bounds = BoxConstrainedSpace(zeros(d), ones(d))
    x = _bcap_candidate_real(population, mass, bounds, rng)
    x .< 0.5
end

function _bcap_candidate(population, mass, searchspace::AtomicSearchSpace, rng)
    rand(rng, searchspace)
end

function SearchSpaces.value(
        sampler::Sampler{S, B}
    ) where {S<:BCAPSampler, B<:Union{BoxConstrainedSpace, BitArraySpace}}
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

function SearchSpaces.value(
        sampler::Sampler{S, B}
    ) where {S<:BCAPSampler, B<:PermutationSpace}

    bcap = sampler.method
    population = bcap.population
    searchspace = sampler.searchspace

    # initialization at random
    if length(population) < bcap.population_size
        return rand(bcap.rng, searchspace)
    end

    k = SearchSpaces.getdim(searchspace)
    # elements to transmit info
    _mask = rand(bcap.rng, eachindex(population), 3)
    # sort regarding maximum mass
    mask = _mask[sortperm(bcap.mass[_mask], rev=true)]

    U = population[mask]
    ps = bcap.mass[mask]
    ps /= sum(ps) # normalize

    val = []
    for (u, p) in zip(U, ps)
        # inherit with maximum probability for each candidate 
        rand(bcap.rng) < p && (continue)
        for v in (u isa Array ? u : [u])
            v in val && (continue)
            push!(val, v)
            break
        end
        length(val) >= k && break
    end

    # complete permutation (if necessary)
    while length(val) < k
        vs = setdiff(searchspace.values, val)
        push!(val, rand(bcap.rng, vs))
    end
    val = [ v for v in val]

    # permutations with length=1, return the value not the array
    if k == length(val) == 1
        return first(val)
    end
    
    val
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
        length(bcap.population) == population_size && _bca_update_mass!(bcap)
        return
    end
    
    # replace worst from old and new
    delete = sortperm(bcap.fitness)[population_size+1:end]
    sort!(delete)
    deleteat!(bcap.population, delete)
    deleteat!(bcap.fitness, delete)

    # update mass values
    _bca_update_mass!(bcap)
end

