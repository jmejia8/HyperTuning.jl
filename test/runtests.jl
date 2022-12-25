using Test
using Parami


@testset verbose = true "API" begin

    @testset "Scenario" begin
        parms = parameters(
                           :x => range(-3, 3),
                           :y => Permutations(4),
                           :N => 1:5
                          )

        scenario = Scenario(parameters = parms,
                            sampler    = AtRandom,
                            pruner     = MedianPruner(),
                            max_trials = 30,
                            max_time   = 60,
                            instances  = 1:10,
                           ) 

        @test scenario isa Scenario

        # @show cardinality(parms)
        # Parami.suggest_budget(scenario)
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

        params = parameters(:x => Bounds(0, 10),
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

            I = get_instance(scenario)

            # handling multiple instances
            if I == 1
                fx = x^2 + prod(y[1:N])
            else
                fx = I*sin(x)^2 + prod(y[1:N])
            end
            
            fx
        end

        params = parameters(:x => -10:10,
                            :y => Permutations(10),
                            :N => 1:10
                           )

        scenario = Scenario(;parameters = params, instances = 1:5)

        Parami.optimize!(f, scenario)
    end

end


