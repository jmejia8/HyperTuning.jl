function sample(scenario::Scenario)
    trials = Trial[]

    if scenario.status.f_evals > scenario.budget.max_trials
        return trials
    end
    
    searchspace = scenario.parameters
 
    value_id = 0
    counter = 0
    for values in scenario.sampler
        # TODO improve instance scheduler
        value_id += 1
        for (instance_id, instance) in enumerate(scenario.instances)
            seed = 1
            fval =  Inf
            push!(trials,Trial(;fval,values,instance,instance_id,seed,value_id))
            counter += 1
        end

        if scenario.status.f_evals + counter >= scenario.budget.max_trials
            break
        end
        
        
    end
    trials
end
