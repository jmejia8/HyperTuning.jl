function evaluate_objective_threads(f::Function, scenario::Scenario)
    verbose = scenario.verbose
    trials = sample(scenario)

    Threads.@threads for i in eachindex(trials)
        evaluate_trial!(f, trials[i], verbose)
    end

    scenario.status.f_evals += length(trials)

    save_trials!(trials, scenario)
end

