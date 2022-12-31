function _suggest(var::Symbol, ::Nothing, trial::Trial)
    return trial.values[var]
end

function _suggest(var::Symbol, ::Nothing, scenario::Scenario)
    return scenario.best_trial.values[var]
end

#=
function get_search_space(scenario::Scenario, key)
    scenario.parameters.domain[key]
end


function _suggest(var::Symbol, ::Nothing, scenario::Scenario)
    if var in keys(scenario.parameters.domain)
        searchspace = get_search_space(scenario, var)
        return SearchSpaces.value(SearchSpaces.Sampler(scenario.sampler, searchspace))
    end

    throw(ErrorException("$var not defined in scenario."))
end


function _register!(var::Symbol, searchspace, scenario::Scenario)
    scenario.parameters.domain[var] = searchspace
end

function _suggest(var::Symbol,searchspace::AbstractSearchSpace,scenario::Scenario)

    # TODO improve performance finding var in keys
    if var in keys(scenario.parameters.domain)
        # TODO compare with saved search space
        searchspace = get_search_space(scenario, var)
        return SearchSpaces.value(SearchSpaces.Sampler(scenario.sampler, searchspace))
    end

    _register!(var, searchspace, scenario)
    SearchSpaces.value(SearchSpaces.Sampler(scenario.sampler, searchspace))
end
=#

function _pre_proc(ex::Expr)
    #=
    if length(ex.args) == 2 # scenario(searchspace)
        return ex.args[1], ex.args[2]
    end
    =#
    throw(ArgumentError)
end

function _pre_proc(scenario::Symbol)
    return scenario, nothing
end

macro suggest(ex::Expr)
    
    if length(ex.args) != 3 || ex.args[1] ∉ [:in, :∈]
        throw(ArgumentError("Expression not valid."))
    end

    var_name = ex.args[2]
    _scenario, _searchspace = _pre_proc(ex.args[3])
    
    quote
        local searchspace = $(esc(_searchspace))
        local scenario = $(esc(_scenario))
        local v = $(QuoteNode(var_name))
        $(esc(var_name)) = _suggest(v, searchspace, scenario)
    end
end
