function get_available_samples(scenario)
    1
end

function evaluate_trial(f, trial::Trial, verbose = false)
    fval = f(trial)
    if isnothing(fval)
        fval = isempty(trial.record) ? Inf : last(trial.record)
        trial.pruned = true
    end

    trial.fval = fval
 
    if verbose
        if trial.pruned
            step = length(trial.record)
            printstyled("[-] Trial ", trial.value_id, " pruned in step ", step," at instance ", trial.instance_id, "\n", color=:light_black)
        else

            c = trial.success ? :green : :default
            m = trial.success ? "[*]" : "[+]"
            printstyled(m, " Trial ", trial.value_id, " evaluated ", trial.fval, " at instance ", trial.instance_id, "\n", color = c)
        end
    end


    trial.fval
end


function evaluate_objective(f::Function, scenario::Scenario)
    sampler = scenario.sampler
    searchspace = scenario.parameters
    verbose = scenario.verbose

    trials = sample(scenario) # sampler(searchspace)

    # TODO parallelize this part
    fvals = [evaluate_trial(f, trial, verbose) for trial in trials]
    scenario.status.f_evals += length(fvals)
    save_trials!(trials, scenario)

    fvals
end

function before_evaluation!(scenario::Scenario)
    scenario
end

function after_evaluation!(scenario::Scenario, f_values)
    report_values_to_sampler!(scenario, f_values)
    update_pruner!(scenario.pruner, scenario.status.history, length(scenario.instances))

    scenario
end

function report_values_to_sampler!(scenario::Scenario, f_values)
    scenario
end

function optimize!(f::Function, scenario::Scenario)
    # prepare the samplers
    before_evaluation!(scenario)

    # get array with f values
    f_values = evaluate_objective(f, scenario)

    # report f values to samplers for further decisions
    after_evaluation!(scenario, f_values)
end


function optimize(f::Function, scenario::Scenario)
    while !budget_exceeded(scenario)
        optimize!(f, scenario)
    end
    scenario
end

