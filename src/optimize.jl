include("evaluator/evaluate_objective.jl")


function before_evaluation!(scenario::Scenario)
    scenario
end

function after_evaluation!(scenario::Scenario)
    update_pruner!(scenario.pruner, scenario.status.history, length(scenario.instances))

    scenario
end

function optimize!(f::Function, scenario::Scenario)
    # prepare some required stuff
    before_evaluation!(scenario)

    # evaluate trails
    evaluate_objective(f, scenario)

    # report f values to samplers for further decisions
    after_evaluation!(scenario)
end


function optimize(f::Function, scenario::Scenario)
    while !budget_exceeded(scenario)
        optimize!(f, scenario)
    end
    scenario
end

