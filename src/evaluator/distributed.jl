function evaluate_objective_distributed(f::Function, scenario::Scenario)
    sampler = scenario.sampler
    searchspace = scenario.parameters
    verbose = scenario.verbose

    trials = sample(scenario)
    trials = pmap(trial -> begin
             evaluate_trial!(f, trial, verbose)
             trial._pruner = NeverPrune() # prevent sending unnecessary data
             trial
         end, trials)

    #=
    @distributed for i in eachindex(trials)
        trial = fetch(trails)[i]
        evaluate_trial!(f, trial, verbose)
    end
    =#

    scenario.status.f_evals += length(trials)

    save_trials!(trials, scenario)
end

