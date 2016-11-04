__precompile__()
module AutoDiffSource

export @δ, checkdiff

export δplus, δminus, δtimes, δdivide, δabs, δsum, δsqrt, δexp, δlog, δpower
export δdotplus, δdotminus, δdottimes, δdotdivide, δdotabs, δdotsqrt, δdotexp, δdotlog, δdotpower
export δplus1, δminus1, δtimes1, δdivide1, δpower1
export δdotplus1, δdotminus1, δdottimes1, δdotdivide1, δdotpower1
export δplus2, δminus2, δtimes2, δdivide2, δpower2
export δdotplus2, δdotminus2, δdottimes2, δdotdivide2, δdotpower2

include("parse.jl")
include("diff.jl")
include("func.jl")
include("checkdiff.jl")

end
