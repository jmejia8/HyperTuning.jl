include("evaluator/evaluate_objective.jl")


function before_evaluation!(scenario::Scenario)
    scenario
end

function after_evaluation!(scenario::Scenario)
    update_pruner!(scenario.pruner, scenario.status.history, length(scenario.instances))

    scenario
end

"""
    optimize!(f, scenario)

Perform an iteration of the optimization process.

When this function is called, `scenario.batch_size` trials are sampled and evaluated,
then update the sampler and pruner.

See also [`optimize`](@ref)
"""
function optimize!(f::Function, scenario::Scenario)
    # prepare some required stuff
    before_evaluation!(scenario)

    # evaluate trails
    evaluate_objective(f, scenario)

    # report f values to samplers for further decisions
    after_evaluation!(scenario)
end


"""
    optimize(f, scenario)

Optimize f on provided scenario while the budget is not exceeded
(limited by max_trials, max_evals, etc).


See also [`optimize!`](@ref)
"""
function optimize(f::Function, scenario::Scenario)
    while !default_stop_criteria(scenario)
        optimize!(f, scenario)
    end
    scenario
end

"""
    budget_exceeded(scenario)

Check whether if budget is not exceeded.
"""
function budget_exceeded(scenario::Scenario)
    status = scenario.status
    if scenario.status.stop
        # nothing to do
        return true
    end
    
    if status.n_trials >= scenario.budget.max_trials
        status.stop = true
        status.stop_reason = BudgetExceeded("Due to max_trials")
    elseif status.f_evals >= scenario.budget.max_evals
        status.stop = true
        status.stop_reason = BudgetExceeded("Due to max_evals")
    end

    status.stop
end

"""
    all_instances_succeeded(scenario)

Check if all instances are successfully solved.

See also [`report_success`](@ref)
"""
function all_instances_succeeded(scenario::Scenario)
    status = scenario.status
    if scenario.status.stop
        # nothing to do
        return true
    end

    scenario.status.stop = allsucceeded(scenario)
    status.stop_reason = AllInstancesSucceeded()
    scenario.status.stop
end
