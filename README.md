# HyperTuning.jl

Automated multi-instance hyperparameters optimization in Julia.

## Installation

This package can be installed on Julia v1.7 and above.

```
pkg> add url_to_this_repo
```

## Quick Start

Let's begin `using HyperTuning` to optimize $f(x,y)=(1-x)^2+(y-1)^2$.
After that, the hyperparameters and budget are given in a new scenario.
Once the scenario and the objective function are defined, the optimization process begins. 

```julia
julia> using HyperTuning

julia> function objective(trial)
           @unpack x, y = trial
           (1 - x)^2 + (y - 1)^2
       end
objective (generic function with 1 method)

julia> scenario = Scenario(x = (-10.0..10.0),
                           y = (-10.0..10.0),
                           max_trials = 200);

julia> HyperTuning.optimize(objective, scenario)
Scenario: evaluated 200 trials.
          parameters: x, y
   space cardinality: Huge!
           instances: 1
          batch_size: 8
             sampler: BCAPSampler{Random.Xoshiro}
              pruner: NeverPrune
          max_trials: 200
           max_evals: 200
         stop_reason: HyperTuning.BudgetExceeded("Due to max_trials")
          best_trial: 
┌───────────┬────────────┐
│     Trial │      Value │
│       198 │            │
├───────────┼────────────┤
│         x │   0.996266 │
│         y │    1.00086 │
│    Pruned │      false │
│   Success │      false │
│ Objective │ 1.46779e-5 │
└───────────┴────────────┘

julia> @unpack x, y = scenario
```

## Features

- **Intuitive usage**: Define easily the objective function, the hyperparameters, start optimization, and nothing more.
- **Muti-instance**: Find the best hyperparameters not for single-application but multiple problem instances, datasets, etc.
- **Parallelization**: Don't worry, simply start `julia -t8` if you have 8 available threads or `julia -p4` if you want 4 parallel processes, and the HyperTuning does the rest.
- **Parameters**: This package is compatible with integer, float, boolean, and categorical parameters; however permutations and vectors of numerical values are compatible.
- **Samplers**: `BCAPSampler` a heuristic sampler, `GridSampler` for brute force, `RandomSampler` for an unbiased search.
- **Pruner**: `NeverPrune` to never prune a trial and `MedianPruner` for early-stopping the algorithm being configured.

## Citation

Please, cite us if you use this package in your research work.

## Contributing

To start contributing to the codebase, consider opening an issue describing the possible changes. PRs fixing typos or grammar issues are always welcome. 
