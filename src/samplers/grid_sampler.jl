# use Grid from SearchSpaces
# const GridSampler = Grid

struct GridSampler <: AbstractSampler
    npartitions::Int
end

function GridSampler(;npartitions = 3)
    GridSampler(npartitions)
end

Sampler(s::GridSampler, parameters::MixedSpace) = Grid(parameters; npartitions=s.npartitions)

