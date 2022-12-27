function budget_exceeded(scenario::Scenario)
    scenario.status.stop = scenario.status.stop ||
    scenario.status.n_trials >= scenario.budget.max_trials ||
    scenario.status.f_evals >= scenario.budget.max_evals

    scenario.status.stop
end

