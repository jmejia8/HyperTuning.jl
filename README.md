

<img align="right" src="https://jmejia8.github.io/HyperTuning.jl/dev/assets/logo.svg" width=300  alt="HyperTuning.jl logo"/>

# HyperTuning.jl

[Installation](#installation) /
[Quick Start](#quick-start) /
[Features](#features) /
[Examples](#examples) /
[Documentation](https://jmejia8.github.io/HyperTuning.jl/dev/)



Automated hyperparameter tuning in Julia.
HyperTuning aims to be intuitive, capable of handling multiple problem instances, and providing easy parallelization.


[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![Doc](https://img.shields.io/badge/docs-dev-blue.svg)](https://jmejia8.github.io/HyperTuning.jl/dev/)


<hr>

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

See [here](https://github.com/jmejia8/hypertuning-examples) for more examples.

## Features

- **Intuitive usage**: Define easily the objective function, the hyperparameters, start optimization, and nothing more.
- **Muti-instance**: Find the best hyperparameters, not for a single application but multiple problem instances, datasets, etc.
- **Parallelization**: Don't worry, simply start `julia -t8` if you have 8 available threads or `julia -p4` if you want 4 distributed processes, and the HyperTuning does the rest.
- **Parameters**: This package is compatible with integer, float, boolean, and categorical parameters; however permutations and vectors of numerical values are compatible.
- **Samplers**: `BCAPSampler` for a heuristic search, `GridSampler` for brute force, and `RandomSampler` for an unbiased search.
- **Pruner**: `NeverPrune` to never prune a trial and `MedianPruner` for early-stopping the algorithm being configured.

## Examples

Examples for different Julia packages.

- Optimization
    * [Metaheuristics](https://github.com/jmejia8/hypertuning-examples/blob/main/Metaheuristics/metaheuristics.jl): The best parameters for a metaheuristic.
    * [Optim](https://github.com/jmejia8/hypertuning-examples/blob/main/Optim/optim.jl): The best parameter for an exact optimizer.
- Machine Learning
    * [MLJ](https://github.com/jmejia8/hypertuning-examples/blob/main/MLJ/mlj.jl): The best hyperparameters for a Machine Learning method.
    * [Flux](https://github.com/jmejia8/hypertuning-examples/blob/main/Flux/flux.jl): The best hyperparameters for an artificial neural network method.

Further examples can be found at [https://github.com/jmejia8/hypertuning-examples](https://github.com/jmejia8/hypertuning-examples)

## Citation

Please, cite us if you use this package in your research work.

> Mejía-de-Dios, JA., Mezura-Montes, E. & Quiroz-Castellanos, M. Automated parameter tuning as a bilevel optimization problem solved by a surrogate-assisted population-based approach. Appl Intell 51, 5978–6000 (2021). https://doi.org/10.1007/s10489-020-02151-y

```bibtex
@article{MejadeDios2021,
  author = {Jes{\'{u}}s-Adolfo Mej{\'{\i}}a-de-Dios and Efr{\'{e}}n Mezura-Montes and Marcela Quiroz-Castellanos},
  title = {Automated parameter tuning as a bilevel optimization problem solved by a surrogate-assisted population-based approach},
  journal = {Applied Intelligence}
  doi = {10.1007/s10489-020-02151-y},
  url = {https://doi.org/10.1007/s10489-020-02151-y},
  year = {2021},
  month = jan,
  publisher = {Springer Science and Business Media {LLC}},
  volume = {51},
  number = {8},
  pages = {5978--6000},
}
```


## Contributing

To start contributing to the codebase, consider opening an issue describing the possible changes.
PRs fixing typos or grammar issues are always welcome. 
