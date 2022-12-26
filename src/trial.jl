Base.@kwdef mutable struct Trial{I}
    values::Dict = Dict()
    fval::Union{Float64, Vector{Float64}} = Inf
    instance::I = 0
    seed::Int = 1
    record::Vector = []
    pruned::Bool = false
end

Base.@kwdef mutable struct StatusParami
    history::Vector{Trial} = Trial[]
    f_evals::Int = 0
    start_time::Float64 = time()
end

get_instance(trial::Trial) = trial.instance
get_seed(trial::Trial) = trial.seed

