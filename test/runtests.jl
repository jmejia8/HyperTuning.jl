using Test
using Parami


# Aqua: Auto QUality Assurance for Julia packages
using Aqua

@testset "ambiguities" begin
    Aqua.test_ambiguities(Parami, recursive = false)
end
Aqua.test_all(Parami, ambiguities = false)


const COMPLEX_PARAMETERS = parameters(
                                      :a => (60.0 .. 200.0),
                                      :b => (1 .. 5),
                                      :x => Bounds([-1,-1.0], [1.0, 1.0]),
                                      :y => Bounds([2, 3, 4], [10, 20, 30]),
                                      :w => BitArrays(3),
                                      :N => 0:10,
                                      :fn => [sin, cos, abs],
                                     )

const AVAILABLE_SAMPLERS = [RandomSampler(), BCAPSampler(), GridSampler()]
const AVAILABLE_PRUNERS  = [NeverPrune(), MedianPruner(start_after=3, prune_after=5)]

@testset verbose = true "API" begin
    function f(trial)
        @unpack a, b = trial
        @suggest N in trial
        @unpack w, x, y, fn = trial

        val = a*(1 + sum(x.^2)) + N - b*sum(y) + sum(w)
        for t in 1:20
            val -= 1/10t
            # report value to pruner
            report_value!(trial, val)
            # successful trial if condition is met
            # check for prune
            should_prune(trial) && (return)
        end

        fv = fn(val)
        fv < -0.9 && report_success!(trial)
        fv
    end

    for sampler in AVAILABLE_SAMPLERS
        for pruner in AVAILABLE_PRUNERS
            # define the scenario
            # deepcopy prevents reuse initialized sampler/pruned
            scenario = Scenario(;
                                parameters = COMPLEX_PARAMETERS,
                                sampler = deepcopy(sampler),
                                pruner  = deepcopy(pruner),
                                max_trials = 25
                               ) 

            # checks before optimization
            @test scenario.pruner isa typeof(pruner)
            @test get_best_values(scenario) |> isempty

            @test Parami.check_scenario(f, scenario, verbose=false)
            Parami.optimize(f, scenario)

            # checks after optimization
            @test get_best_values(scenario) in COMPLEX_PARAMETERS
            @test history(scenario) isa Array
            @test length(top_parameters(scenario)) <= length(history(scenario))
        end
    end
end
