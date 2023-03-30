using Test
using HyperTuning


# Aqua: Auto QUality Assurance for Julia packages
using Aqua

@testset "ambiguities" begin
    Aqua.test_ambiguities(HyperTuning, recursive = false)
end
Aqua.test_all(HyperTuning, ambiguities = false)


const COMPLEX_PARAMETERS = parameters(
                                      :a => (60.0 .. 200.0),
                                      :b => (1 .. 5),
                                      :x => BoxConstrainedSpace([-1,-1.0], [1.0, 1.0]),
                                      :y => BoxConstrainedSpace([2, 3, 4], [10, 20, 30]),
                                      :w => BitArraySpace(3),
                                      :N => 0:10,
                                      :fn => [sin, cos, abs],
                                     )

const AVAILABLE_SAMPLERS = [RandomSampler(), BCAPSampler(), GridSampler()]
const AVAILABLE_PRUNERS  = [NeverPrune(), MedianPruner(start_after=3, prune_after=5)]


@testset verbose = true "Unitary" begin
    @testset verbose = true "Scenario" begin
        scenario = Scenario(
                            a = BoxConstrainedSpace(zeros(10), ones(10)),
                            b = BoxConstrainedSpace(zeros(Int,10), ones(Int, 10)),
                            c = PermutationSpace(4),
                            d = BitArraySpace(6),
                            x = (-1.0..1),
                            y = (0..0),
                            z = [:red, :green],
                           )
        @test rand(scenario.parameters) in scenario.parameters
        # @unpack a, b, c, d, x, y, z = scenario
    end
end

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

            @test HyperTuning.check_scenario(f, scenario, verbose=false)
            HyperTuning.optimize(f, scenario)

            # checks after optimization
            @test get_best_values(scenario) in COMPLEX_PARAMETERS
            @test history(scenario) isa Array
            @test length(top_parameters(scenario)) <= length(history(scenario))
        end
    end
end
