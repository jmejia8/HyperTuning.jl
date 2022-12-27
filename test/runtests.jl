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
                fval =  (x)^2 + prod(y[1:N])
            else
                fval = (x - 1/my_instance)^2 + sum(y[N+1:end])
            end

            current_val = 0.0
            for iter in 1:19
                current_val = fval + 19/iter - 1
                report_value!(trial, current_val)
                should_prune(trial) && (return)
            end

            fval = current_val


            fval <= 1 && report_success!(trial)
            fval
        end

        params = parameters(:x => range(-1, 1, length = 5),
                            :y => Permutations(4),
                            :N => 1:4
                           )

        scenario = Scenario(;parameters = params,
                            instances  = 1:3,
                            sampler = Grid,
                            pruner = MedianPruner(),
                            verbose=false,
                           )

        Parami.optimize(f, scenario)
        display(top_parameters(scenario))
        #display(best_parameters(scenario))
        #display(scenario.status.history)
        #display(best_parameters(scenario).trials[1])
        @test Parami.trial_performance(scenario.best_trial) isa Real
    end

    @testset "Expensive" begin

        function f(trial)
            @suggest x in trial
            @suggest y in trial
            @suggest z in trial

            g = get_instance(trial)
            fval =  x^2 + y^2 + z^2 + g(x + y + z)

            current_val = 0.0
            for iter in 1:50
                current_val = fval + 19/iter - 1
                report_value!(trial, current_val)
                should_prune(trial) && (return)
            end

            fval = current_val

            fval <= 0 && report_success!(trial)
            fval
        end

        params = parameters(:x => range(-1, 1, length = 5),
                            :y => range(-1, 1, length = 5),
                            :z => range(-1, 1, length = 5)
                           )

        scenario = Scenario(;parameters = params,
                            instances  = [sin, cos, abs],
                            sampler = Grid,
                            pruner = MedianPruner(),
                            verbose=true,
                           )
        Parami.optimize(f, scenario)
        display(top_parameters(scenario))
        # display(scenario.status.history)

    end

end


