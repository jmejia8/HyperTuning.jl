include("sequential.jl")
include("threads.jl")

function evaluate_objective(f::Function, scenario::Scenario)
    # Folds.map( pp -> pp.i, p , ThreadedEx())
    if Threads.nthreads() > 0
        evaluate_objective_threads(f, scenario)
    else
        evaluate_objective_sequential(f, scenario)
    end
    
end
