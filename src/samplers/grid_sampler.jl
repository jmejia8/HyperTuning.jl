# use Grid from SearchSpaces
# const GridSampler = Grid

struct GridSampler <: AbstractSampler
    npartitions::Int
end

"""
    GridSampler(;npartitions)

Define a iterator for the grid sampler.
"""
function GridSampler(;npartitions = 3)
    GridSampler(npartitions)
end

Sampler(s::GridSampler, parameters::MixedSpace) = Grid(parameters; npartitions=s.npartitions)

