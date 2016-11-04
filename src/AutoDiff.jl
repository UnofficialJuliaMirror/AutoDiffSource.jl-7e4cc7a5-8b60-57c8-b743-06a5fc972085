__precompile__()
module AutoDiff

export @δ, checkdiff

export δplus, δminus, δtimes, δdivide, δabs, δsum

include("parse.jl")
include("diff.jl")
include("func.jl")
include("checkdiff.jl")

end # module
