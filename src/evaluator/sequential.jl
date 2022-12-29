function evaluate_trial!(f, trial::Trial, verbose = false)
    fval = f(trial)
    if isnothing(fval)
        fval = isempty(trial.record) ? Inf : last(trial.record)
        trial.pruned = true
    end

    trial.fval = fval
 
    verbose && print_trial(trial)

    trial.fval
end

function evaluate_objective_sequential(f::Function, scenario::Scenario)
    verbose = scenario.verbose
    trials = sample(scenario)

    for i in eachindex(trials)
        evaluate_trial!(f, trials[i], verbose)
    end
    scenario.status.f_evals += length(trials)
    save_trials!(trials, scenario)

end

