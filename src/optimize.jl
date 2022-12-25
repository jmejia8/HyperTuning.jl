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


function before_evaluation!(scenario::Scenario)
    # budget = scenario.budget
    schedule_experiements!(scenario)

    scenario
end

function schedule_experiements!(scenario::Scenario)
    # remove last experiments
    empty!(scenario.experiments)

    history_max_len = scheduler.status.history_max_len

    # create new experiments
    # TODO improve experiment scheduler
    for (i, instance) in enumerate(scenario.instances)
        for _ in 1:history_max_len
            push!(scenario.experiments, Experiment(Dict(), [], instance, i))
        end
    end

    scenario
end

function evaluate_objective(f::Function, scenario::Scenario)

    # TODO parallelize this part
    f_values = [f(scenario) for _ in eachindex(scenario.experiments)]
    
    status = scenario.status
    status.n_evaluations += length(f_values)
    f_values
end


function update_history(scenario::Scenario)
    evaluated_trials = get_last_trials(scenario)

end


function after_evaluation!(scenario::Scenario, f_values)
    report_values_to_sampler!(scenario, f_values)
    scenario
end

function report_values_to_sampler!(scenario::Scenario, f_values)
    scenario
end

