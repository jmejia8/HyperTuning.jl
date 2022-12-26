function get_available_samples(scenario)
    1
end

function evaluate_trial(f, trial::Trial)
    fval = f(trial)
    if isnothing(fval)
        fval = Inf
        trial.prunded = true
    end

    trial.fval = fval
    trial.fval
end


function evaluate_objective(f::Function, scenario::Scenario)
    sampler = scenario.sampler
    searchspace = scenario.parameters

    trials = sample(scenario) # sampler(searchspace)
    # TODO improve instances scheduler
    # instances = scenario.instances

    # TODO parallelize this part
    fvals = [evaluate_trial(f, trial) for trial in trials]
    scenario.status.f_evals += length(fvals)
    save_trials!(trials, scenario)

    fvals
end

function before_evaluation!(scenario::Scenario)
    scenario
end

function after_evaluation!(scenario::Scenario, f_values)
    report_values_to_sampler!(scenario, f_values)

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
    while !should_stop(scenario)
        optimize!(f, scenario)
    end
    scenario
end

