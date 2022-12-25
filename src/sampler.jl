abstract type SamplerParami end

# this function is called on _suggest
function sample(
        var::Symbol,
        searchspace::AbstractSearchSpace,
        scenario::Scenario
    )
    val = sample(var, scenario.sampler, searchspace, scenario)
    scenario.experiments

    val
end

# interface for SearchSpaces
function sample(
        var::Symbol,
        sampler::AbstractSampler,
        searchspace::AbstractSearchSpace,
        scenario::Scenario
    )
    # value receives a Sampler struct
    s = SearchSpaces.Sampler(scenario.sampler, searchspace)
    # sample a value in sampler
    SearchSpaces.value(s)
end

function sample(
        var::Symbol,
        sampler::SamplerParami,
        searchspace::AbstractSearchSpace,
        scenario::Scenario
    )
    # TODO
end

