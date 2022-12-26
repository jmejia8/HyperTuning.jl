function sample(scenario::Scenario)
    trials = Trial[]

    if scenario.status.f_evals > scenario.budget.max_trials
        return trials
    end
    
    searchspace = scenario.parameters
 
    counter = 0
    for values in scenario.sampler
        # TODO improve instance scheduler
        scenario.status.n_trials += 1
        value_id = scenario.status.n_trials
        for (instance_id, instance) in enumerate(scenario.instances)
            seed = 1
            fval =  Inf
            push!(trials,Trial(;fval,values,instance,instance_id,seed,value_id))
            counter += 1
        end

        if budget_exceeded(scenario)
            break
        end
    end

    trials
end
