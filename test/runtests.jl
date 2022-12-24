using Test
using Parami


@testset verbose = true "API" begin

    @testset "Scenario" begin
        parms = parameters(
                           :x => Bounds(0.0, 10),
                           :y => Permutations(10),
                           :N => 1:10
                          )

        scenario = Scenario(parameters = parms,
                            sampler    = AtRandom,
                            pruner     = MedianPruner(),
                            max_trials = 30,
                            max_time   = 60,
                            instances  = 1:10,
                           ) 

        @test scenario isa Scenario
    end

    @testset "Suggester" begin
        # empty scenario
        scenario = Scenario(max_trials = 10)

        @suggest x in scenario(Categorical([:red, :green, :blue]))
        @test x in [:red, :green, :blue]
        @suggest x in scenario
        @test x in [:red, :green, :blue]

    end

    @testset "Objective" begin
        function f(scenario)
            @suggest x in scenario
            @suggest y in scenario
            @suggest N in scenario
            x^2 + prod(y[1:N])
        end

        params = parameters(:x => Bounds(0.0, 10),
                            :y => Permutations(10),
                            :N => 1:10
                           )
        scenario = Scenario(;parameters = params)
        @test f(scenario) isa Real
    end

    @testset "Optimize" begin
        function f(scenario)
            @suggest x in scenario
            @suggest y in scenario
            @suggest N in scenario

            fx = x^2 + prod(y[1:N])
            @show fx
            fx
        end

        params = parameters(:x => Bounds(0.0, 10),
                            :y => Permutations(10),
                            :N => 1:10
                           )

        scenario = Scenario(;parameters = params)

        Parami.optimize!(f, scenario)
    end

end


