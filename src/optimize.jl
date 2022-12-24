function get_available_samples(scenario)
    1
end

function evaluate_objective(f::Function, scenario::Scenario)
    # TODO parallelize this part
    [f(scenario) for _ in get_available_samples(scenario)]
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

