include("grid_sampler.jl")
include("random_sampler.jl")
include("bcap_sampler.jl")

report_values_to_sampler!(sampler::Sampler, trials) = nothing

function report_values_to_sampler!(sampler::Sampler{R, P}, trials::Array) where {R <: Dict, P <: MixedSpace}
    if isempty(trials)
        return
    end

    
    for p in sampler.method
        k, samp = p
        data = [(trial.values[k], trial.performance) for trial in trials]
        report_values_to_sampler!(samp, data)
    end
end

function sample(scenario::Scenario)
    trials = Trial[]

    searchspace = scenario.parameters
 
    counter = 0
    _pruner = scenario.pruner
    for values in scenario.sampler
        scenario.status.n_trials += 1
        value_id = scenario.status.n_trials
        # TODO improve instance scheduler
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

    if counter == 0
        scenario.status.stop = true
        scenario.status.stop_reason = NoMoreTrials()
    end
    

    trials
end

