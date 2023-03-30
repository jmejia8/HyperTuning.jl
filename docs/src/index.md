```@meta
CurrentModule = HyperTuning
```

# HyperTuning.jl

[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![Optimized using HyperTuning](https://raw.githubusercontent.com/jmejia8/HyperTuning.jl/main/badge.svg)](https://github.com/jmejia8/HyperTuning.jl)

Automated hyperparameter tuning in Julia.
HyperTuning aims to be intuitive, capable of handling multiple problem instances, and providing easy parallelization.

## Installation


This package can be installed on Julia v1.7 and above. Use one of the following options.

Via Pkg module:

```julia
julia> import Pkg; Pkg.add("HyperTuning")
```


Via the Julia package manager, type `]` and

```
pkg> add HyperTuning
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
- **Muti-instance**: Find the best hyperparameters, not for a single application but multiple problem instances, datasets, etc.
- **Parallelization**: Don't worry, simply start `julia -t8` if you have 8 available threads or `julia -p4` if you want 4 distributed processes, and the HyperTuning does the rest.
- **Parameters**: This package is compatible with integer, float, boolean, and categorical parameters; however permutations and vectors of numerical values are compatible.
- **Samplers**: `BCAPSampler` for a heuristic search, `GridSampler` for brute force, and `RandomSampler` for an unbiased search.
- **Pruner**: `NeverPrune` to never prune a trial and `MedianPruner` for early-stopping the algorithm being configured.

## Citation

Please, cite us if you use this package in your research work.

> Mejía-de-Dios, JA., Mezura-Montes, E. & Quiroz-Castellanos, M. Automated parameter tuning as a bilevel optimization problem solved by a surrogate-assisted population-based approach. Appl Intell 51, 5978–6000 (2021). https://doi.org/10.1007/s10489-020-02151-y

```bibtex
@article{MejadeDios2021,
  author = {Jes{\'{u}}s-Adolfo Mej{\'{\i}}a-de-Dios and Efr{\'{e}}n Mezura-Montes and Marcela Quiroz-Castellanos},
  title = {Automated parameter tuning as a bilevel optimization problem solved by a surrogate-assisted population-based approach},
  journal = {Applied Intelligence},
  doi = {10.1007/s10489-020-02151-y},
  url = {https://doi.org/10.1007/s10489-020-02151-y},
  year = {2021},
  publisher = {Springer Science and Business Media {LLC}},
  volume = {51},
  number = {8},
  pages = {5978--6000}
}
```

## Badge

Add the following in your Markdown docstring:

```
[![Optimized using HyperTuning](https://raw.githubusercontent.com/jmejia8/HyperTuning.jl/main/badge.svg)](https://github.com/jmejia8/HyperTuning.jl)
```

to show the badge [![Optimized using HyperTuning](https://raw.githubusercontent.com/jmejia8/HyperTuning.jl/main/badge.svg)](https://github.com/jmejia8/HyperTuning.jl)


## Contributing

To start contributing to the codebase, consider opening an issue describing the possible changes.
PRs fixing typos or grammar issues are always welcome. 
