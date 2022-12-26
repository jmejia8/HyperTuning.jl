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
                return (10x)^2 + prod(y[1:N])
            end
            
            my_instance*cos(π*x)^2 + sum(y[N+1:end])
        end

        params = parameters(:x => range(-1, 1, length = 5),
                            :y => Permutations(4),
                            :N => 1:4
                           )

        scenario = Scenario(;parameters = params,
                            instances  = 1:3,
                            sampler = Grid,
                            max_trials = Int(cardinality(params)*3),
                            verbose=true,
                           )

        Parami.optimize!(f, scenario)
        display(scenario.best_trial)
        @test Parami.trial_performance(scenario.best_trial) ≈ 19
    end

end


