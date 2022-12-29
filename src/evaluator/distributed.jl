function evaluate_objective_distributed(f::Function, scenario::Scenario)
    verbose = scenario.verbose

    trials = sample(scenario)
    trials = pmap(trial -> begin
                      evaluate_trial!(f, trial, verbose)
                      # prevent sending back unnecessary data
                      trial._pruner = NeverPrune() 
                      trial
                  end, trials)

    scenario.status.f_evals += length(trials)

    save_trials!(trials, scenario)
end

