include("sequential.jl")
include("threads.jl")
include("distributed.jl")

function evaluate_objective(f::Function, scenario::Scenario)
    #  TODO improve selecting parallelization
    if Threads.nthreads() > 1
        evaluate_objective_threads(f, scenario)
    elseif nprocs() > 1
        evaluate_objective_distributed(f, scenario)
    else
        evaluate_objective_sequential(f, scenario)
    end
    
end
