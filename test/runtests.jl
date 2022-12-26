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


    @testset "Objective" begin
        function f(trial)
            @suggest x in trial
            @suggest y in trial
            @suggest N in trial

            x^2 + prod(y[1:N])
        end

        params = parameters(:x => Bounds(0.0, 10),
                            :y => Permutations(10),
                            :N => 1:10
                           )
        scenario = Scenario(;parameters = params)
        # @test f(scenario) isa Real
    end

    @testset "Optimize" begin
        function f(trial)
            @suggest x in trial
            @suggest y in trial
            @suggest N in trial

            my_instance = get_instance(trial)
            if my_instance == 1
                return x^2 + prod(y[1:N])
            end
            
            my_instance*sin(x)^2 + sum(y[1:N])
        end

        params = parameters(:x => range(-10, 10, length = 5),
                            :y => Permutations(4),
                            :N => 1:4
                           )

        scenario = Scenario(;parameters = params, instances  = 1:3)

        Parami.optimize!(f, scenario)
        @test scenario.best_trial.fval isa Real
    end

end


