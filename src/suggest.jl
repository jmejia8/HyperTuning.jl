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
    error("Expression needs to be of form `x in trial`")
end

function _pre_proc(scenario::Symbol)
    return scenario, nothing
end

function _exec_suggest(var_name::Symbol, _scenario::Symbol, _searchspace)
    quote
        local searchspace = $(esc(_searchspace))
        local scenario = $(esc(_scenario))
        local v = $(QuoteNode(var_name))
        $(esc(var_name)) = _suggest(v, searchspace, scenario)
    end
end

function _suggest_single(ex::Expr)
    var_name = ex.args[2]
    _scenario, _searchspace = _pre_proc(ex.args[3])
    _exec_suggest(var_name, _scenario, _searchspace)
    
end

"""
    @suggest x in trial

Return a value for x stored in the sampled trial.
"""
macro suggest(ex::Expr)
    if length(ex.args) == 3 && ex.args[1] ∈ [:in, :∈]
        return _suggest_single(ex)
    end

    error("Expression needs to be of form `x in trial`")
    
end
