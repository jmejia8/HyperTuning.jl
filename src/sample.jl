function sample(scenario::Scenario)
    searchspace = scenario.parameters
    trials = Trial[]

    value_id = 0
    # FIXME remove zip
    for (values, _) in zip(scenario.sampler, 1:100)
        # TODO improve instance scheduler
        value_id += 1
        for (instance_id, instance) in enumerate(scenario.instances)
            seed = 1
            fval =  Inf
            push!(trials,Trial(;fval,values,instance,instance_id,seed,value_id))
        end
    end
    trials
end
