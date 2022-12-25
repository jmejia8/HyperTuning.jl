Base.@kwdef  struct Record{T, I}
    record::Vector{T}
    instance::I
    pruned::Bool
end

Base.@kwdef struct Trial{T, I}
    trial::Dict             = Dict()    # values for the parameters
    function_values::Vector = []       # objective function value
    record::Vector{Record}  = Record[] # convergence for each instance
end

Base.@kwdef  mutable struct StatusParami{P}# where P <: Trial
    best_trial::P         = Trial()
    history::Vector{P}    = Trial[]
    history_max_len::Int  = 0
    start_time::Float64   = time()
    overall_time::Float64 = 0.0
    n_evaluations::Int    = 0
end

function update_history!(status::StatusParami, trials, fvalues, records, instances)
    @assert length(trials) == length(fvalues) == length(records)

    for i in 1:length(trials)
        trial = trials[i]
        function_value = fvalues[i]
        record = records[i]
        instance = instances[i]

        # check pruned trials
        if !isnothing(function_value)
            push!(status.history_pruned, Trial(;trial, NaN, record))
            continue
        end
        push!(status.history, Trial(;trial, function_value, record))
    end

    if length(status.history) > 
        
    end
    

end

