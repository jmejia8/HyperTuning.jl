function evaluate_objective_threads(f::Function, scenario::Scenario)
    sampler = scenario.sampler
    searchspace = scenario.parameters
    verbose = scenario.verbose

    trials = sample(scenario) # sampler(searchspace)

    Threads.@threads for i in eachindex(trials)
        evaluate_trial!(f, trials[i], verbose)
    end

    scenario.status.f_evals += length(trials)

    save_trials!(trials, scenario)
end

