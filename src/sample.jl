function sample(scenario::Scenario)
    trials = Trial[]

    if scenario.status.f_evals > scenario.budget.max_evals
        # TODO add message for this stopping criteria
        scenario.status.stop = true
        return trials
    end
    
    searchspace = scenario.parameters
 
    counter = 0
    _pruner = scenario.pruner
    for values in scenario.sampler
        # TODO improve instance scheduler
        scenario.status.n_trials += 1
        value_id = scenario.status.n_trials
        for (instance_id, instance) in enumerate(scenario.instances)
            seed = 1
            fval =  Inf
            push!(trials,Trial(;fval,values,instance,instance_id,seed,value_id,_pruner))
            counter += 1
        end

        if budget_exceeded(scenario) || counter >= scenario.batch_size
            break
        end
    end

    # scenario.verbose && counter > 0 && @info "Evaluating batch with $counter trials..."

    if counter == 0
        # TODO add message for this stopping criteria
        scenario.status.stop = true
    end
    

    trials
end
