var documenterSearchIndex = {"docs":
[{"location":"api/","page":"API References","title":"API References","text":"CurrentModule = HyperTuning","category":"page"},{"location":"api/#API-References","page":"API References","title":"API References","text":"","category":"section"},{"location":"api/","page":"API References","title":"API References","text":"","category":"page"},{"location":"api/","page":"API References","title":"API References","text":"Modules = [HyperTuning]","category":"page"},{"location":"api/#HyperTuning.BCAPSampler-Tuple{}","page":"API References","title":"HyperTuning.BCAPSampler","text":"BCAPSampler(searchspace;rng)\n\nDefine a iterator for the BCAP sampler.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.BudgetExceeded","page":"API References","title":"HyperTuning.BudgetExceeded","text":"BudgetExceeded([msg])\n\nUsed to inform if budget has been exceeded.\n\n\n\n\n\n","category":"type"},{"location":"api/#HyperTuning.GridSampler-Tuple{}","page":"API References","title":"HyperTuning.GridSampler","text":"GridSampler(;npartitions)\n\nDefine a iterator for the grid sampler.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.GroupedTrial","page":"API References","title":"HyperTuning.GroupedTrial","text":"GroupedTrial\n\nTrials grouped per instance.\n\n\n\n\n\n","category":"type"},{"location":"api/#HyperTuning.MedianPruner","page":"API References","title":"HyperTuning.MedianPruner","text":"MedianPruner(;start_after, prune_after)\n\nstart_after: Start up pruner after this number (of completed trials).\nprune_after: Prune a trial after this value (considering the median criteria).\nmedian_vals: median values reported for each instance.\n\n\n\n\n\n","category":"type"},{"location":"api/#HyperTuning.NoMoreTrials","page":"API References","title":"HyperTuning.NoMoreTrials","text":"NoMoreTrials()\n\nUsed to inform that ampler refuses to suggest trials.\n\n\n\n\n\n","category":"type"},{"location":"api/#HyperTuning.RandomSampler-Tuple{}","page":"API References","title":"HyperTuning.RandomSampler","text":"RandomSampler(;seed, rng)\n\nDefine a iterator for the random sampler.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.Scenario-Tuple{}","page":"API References","title":"HyperTuning.Scenario","text":"Scenario(;\n        parameters...,\n        sampler    = default_sampler(),\n        pruner     = default_pruner(),\n        instances  = [1],\n        max_trials = :auto,\n        max_evals  = :auto,\n        max_time   = :auto,\n        verbose    = false,\n        batch_size = max(nprocs(), Sys.CPU_THREADS),\n    )\n\nDefine an Scenario with parameters, and budget.\n\nsampler sampler to be used.\npruner pruner to reduce computational cost.\ninstances array (iterator) containing the problem instances.\nmax_trials maximum number of trials to be evaluated on optimize.\nmax_evals maximum number of function evaluations.\nmax_time maximum execution time on optimize.\nverbose show message during the optimization.\nbatch_size number of trials evaluated for each instance for each iteration.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.StatusHyperTuning","page":"API References","title":"HyperTuning.StatusHyperTuning","text":"StatusHyperTuning\n\nCurrent status of the optimize process for scenario.\n\n\n\n\n\n","category":"type"},{"location":"api/#HyperTuning.:..-Tuple{Real, Real}","page":"API References","title":"HyperTuning.:..","text":"..(a, b)\n\nDefine a interval between a and b (inclusive).\n\nSee also Bounds\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.all_instances_succeeded-Tuple{Scenario}","page":"API References","title":"HyperTuning.all_instances_succeeded","text":"all_instances_succeeded(scenario)\n\nCheck if all instances are successfully solved.\n\nSee also report_success\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.best_parameters-Tuple{Any}","page":"API References","title":"HyperTuning.best_parameters","text":"best_parameters(scenario)\n\nReturn best parameters saved in scenario.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.budget_exceeded-Tuple{Scenario}","page":"API References","title":"HyperTuning.budget_exceeded","text":"budget_exceeded(scenario)\n\nCheck whether if budget is not exceeded.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.default_rng_ht","page":"API References","title":"HyperTuning.default_rng_ht","text":"default_rng_ht(seed)\n\nDefault random number generator in HyperTuning.\n\n\n\n\n\n","category":"function"},{"location":"api/#HyperTuning.get_convergence-Tuple{Scenario}","page":"API References","title":"HyperTuning.get_convergence","text":"get_convergence(scenario)\n\nReturn vector of tuples containing the trial id and objective value.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.get_instance-Tuple{HyperTuning.Trial}","page":"API References","title":"HyperTuning.get_instance","text":"get_instance(trial)\n\nGet instance problem which trials has to be evaluated.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.history-Tuple{Scenario}","page":"API References","title":"HyperTuning.history","text":"history(scenario)\n\nReturn all evaluated trails.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.optimize!-Tuple{Function, Scenario}","page":"API References","title":"HyperTuning.optimize!","text":"optimize!(f, scenario)\n\nPerform an iteration of the optimization process.\n\nWhen this function is called, scenario.batch_size trials are sampled and evaluated, then update the sampler and pruner.\n\nSee also optimize\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.optimize-Tuple{Function, Scenario}","page":"API References","title":"HyperTuning.optimize","text":"optimize(f, scenario)\n\nOptimize f on provided scenario while the budget is not exceeded (limited by maxtrials, maxevals, etc).\n\nSee also optimize!\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.parameters-Tuple{Vararg{Pair}}","page":"API References","title":"HyperTuning.parameters","text":"parameters(hyperparameters...)\n\nDefine hyperparameters.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.report_success!-Tuple{HyperTuning.Trial}","page":"API References","title":"HyperTuning.report_success!","text":"report_success!(trial)\n\nReport that the trial successfully solved the instance.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.report_value!-Tuple{HyperTuning.Trial, Any}","page":"API References","title":"HyperTuning.report_value!","text":"report_value!(trial, value)\n\nReport (to the pruner) evaluated value at trail.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.save_trials!-Tuple{Vector{<:HyperTuning.Trial}, Scenario}","page":"API References","title":"HyperTuning.save_trials!","text":"save_trials!(ungrouped_trials, scenario)\n\nSave evaluated trials into scenario history, then update best trial found so far. Also, report values to the sampler.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.should_prune-Tuple{HyperTuning.Trial}","page":"API References","title":"HyperTuning.should_prune","text":"should_prune(trial)\n\nCheck whether trial should be pruned.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.top_parameters-Tuple{Any}","page":"API References","title":"HyperTuning.top_parameters","text":"top_parameters(scenario; ignore_pruned)\n\nReturn an array of trade-off trials (regarding success, mean objective value, time, etc).\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.update_best_trial!-Tuple{Scenario, Vector{HyperTuning.GroupedTrial}}","page":"API References","title":"HyperTuning.update_best_trial!","text":"update_best_trial!(scenario, trials)\n\nUpdate best trial found so far.\n\n\n\n\n\n","category":"method"},{"location":"api/#HyperTuning.@suggest-Tuple{Expr}","page":"API References","title":"HyperTuning.@suggest","text":"@suggest x in trial\n\nReturn a value for x stored in the sampled trial.\n\n\n\n\n\n","category":"macro"},{"location":"","page":"Index","title":"Index","text":"CurrentModule = HyperTuning","category":"page"},{"location":"#HyperTuning.jl","page":"Index","title":"HyperTuning.jl","text":"","category":"section"},{"location":"","page":"Index","title":"Index","text":"(Image: Aqua QA) (Image: Optimized using HyperTuning)","category":"page"},{"location":"","page":"Index","title":"Index","text":"Automated hyperparameter tuning in Julia. HyperTuning aims to be intuitive, capable of handling multiple problem instances, and providing easy parallelization.","category":"page"},{"location":"#Installation","page":"Index","title":"Installation","text":"","category":"section"},{"location":"","page":"Index","title":"Index","text":"This package can be installed on Julia v1.7 and above.","category":"page"},{"location":"","page":"Index","title":"Index","text":"pkg> add https://github.com/jmejia8/HyperTuning.jl","category":"page"},{"location":"#Quick-Start","page":"Index","title":"Quick Start","text":"","category":"section"},{"location":"","page":"Index","title":"Index","text":"Let's begin using HyperTuning to optimize f(xy)=(1-x)^2+(y-1)^2. After that, the hyperparameters and budget are given in a new scenario. Once the scenario and the objective function are defined, the optimization process begins. ","category":"page"},{"location":"","page":"Index","title":"Index","text":"julia> using HyperTuning\n\njulia> function objective(trial)\n           @unpack x, y = trial\n           (1 - x)^2 + (y - 1)^2\n       end\nobjective (generic function with 1 method)\n\njulia> scenario = Scenario(x = (-10.0..10.0),\n                           y = (-10.0..10.0),\n                           max_trials = 200);\n\njulia> HyperTuning.optimize(objective, scenario)\nScenario: evaluated 200 trials.\n          parameters: x, y\n   space cardinality: Huge!\n           instances: 1\n          batch_size: 8\n             sampler: BCAPSampler{Random.Xoshiro}\n              pruner: NeverPrune\n          max_trials: 200\n           max_evals: 200\n         stop_reason: HyperTuning.BudgetExceeded(\"Due to max_trials\")\n          best_trial: \n┌───────────┬────────────┐\n│     Trial │      Value │\n│       198 │            │\n├───────────┼────────────┤\n│         x │   0.996266 │\n│         y │    1.00086 │\n│    Pruned │      false │\n│   Success │      false │\n│ Objective │ 1.46779e-5 │\n└───────────┴────────────┘\n\njulia> @unpack x, y = scenario","category":"page"},{"location":"#Features","page":"Index","title":"Features","text":"","category":"section"},{"location":"","page":"Index","title":"Index","text":"Intuitive usage: Define easily the objective function, the hyperparameters, start optimization, and nothing more.\nMuti-instance: Find the best hyperparameters, not for a single application but multiple problem instances, datasets, etc.\nParallelization: Don't worry, simply start julia -t8 if you have 8 available threads or julia -p4 if you want 4 distributed processes, and the HyperTuning does the rest.\nParameters: This package is compatible with integer, float, boolean, and categorical parameters; however permutations and vectors of numerical values are compatible.\nSamplers: BCAPSampler for a heuristic search, GridSampler for brute force, and RandomSampler for an unbiased search.\nPruner: NeverPrune to never prune a trial and MedianPruner for early-stopping the algorithm being configured.","category":"page"},{"location":"#Citation","page":"Index","title":"Citation","text":"","category":"section"},{"location":"","page":"Index","title":"Index","text":"Please, cite us if you use this package in your research work.","category":"page"},{"location":"","page":"Index","title":"Index","text":"Mejía-de-Dios, JA., Mezura-Montes, E. & Quiroz-Castellanos, M. Automated parameter tuning as a bilevel optimization problem solved by a surrogate-assisted population-based approach. Appl Intell 51, 5978–6000 (2021). https://doi.org/10.1007/s10489-020-02151-y","category":"page"},{"location":"","page":"Index","title":"Index","text":"@article{MejadeDios2021,\n  author = {Jes{\\'{u}}s-Adolfo Mej{\\'{\\i}}a-de-Dios and Efr{\\'{e}}n Mezura-Montes and Marcela Quiroz-Castellanos},\n  title = {Automated parameter tuning as a bilevel optimization problem solved by a surrogate-assisted population-based approach},\n  journal = {Applied Intelligence},\n  doi = {10.1007/s10489-020-02151-y},\n  url = {https://doi.org/10.1007/s10489-020-02151-y},\n  year = {2021},\n  publisher = {Springer Science and Business Media {LLC}},\n  volume = {51},\n  number = {8},\n  pages = {5978--6000}\n}","category":"page"},{"location":"#Badge","page":"Index","title":"Badge","text":"","category":"section"},{"location":"","page":"Index","title":"Index","text":"Add the following in your Markdown docstring:","category":"page"},{"location":"","page":"Index","title":"Index","text":"[![Optimized using HyperTuning](https://raw.githubusercontent.com/jmejia8/HyperTuning.jl/main/badge.svg)](https://github.com/jmejia8/HyperTuning.jl)","category":"page"},{"location":"","page":"Index","title":"Index","text":"to show the badge (Image: Optimized using HyperTuning)","category":"page"},{"location":"#Contributing","page":"Index","title":"Contributing","text":"","category":"section"},{"location":"","page":"Index","title":"Index","text":"To start contributing to the codebase, consider opening an issue describing the possible changes. PRs fixing typos or grammar issues are always welcome. ","category":"page"}]
}
