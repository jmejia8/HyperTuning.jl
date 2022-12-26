function sample(scenario::Scenario)
    searchspace = scenario.parameters
    trials = Trial[]

    # FIXME remove zip
    for (values, _) in zip(scenario.sampler, 1:10)
        # TODO improve instance scheduler
        for instance in scenario.instances
            seed = 1
            push!(trials, Trial(;fval = Inf, values, instance, seed))
        end
    end
    trials
end
