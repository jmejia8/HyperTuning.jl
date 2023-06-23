function check_scenario(f::Function, scenario::Scenario; verbose=true)
    trials = nothing
    try
        trials = sample(scenario::Scenario)
    catch e
        @error "HyperTuning: I cannot sample trials due to:"
        println("Error: ", e)
        return false
    end

    if isempty(trials)
        @error "HyperTuning: I cannot sample trials."
        println("Check sampler o parameters config.")
        println("Provided parameters: ", scenario.parameters)
        println("Provided Sampler: ", scenario.sampler)
        return false
    end

    trial = first(trials)

    fv = nothing
    try
        fv = f(trial)
    catch  e
        @error "HyperTuning: Objective function contains the following error:"
        println(e)
        return false
    end
    
    # TODO consider multi-objective
    if !trial.pruned && !(fv isa Number)
        @error "HyperTuning: Objective function must report a numerical value (except for pruned trials)."
        println("Value reported: ", fv)
        return false
    end

    if verbose
        @info "HyperTuning: Sampler and Objective function did not report errors."
        println("Evaluated trial: ")
        display(trial.values)
        println("")
        @info "Done."
    end
    
    true
end

