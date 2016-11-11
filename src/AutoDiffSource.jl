__precompile__()
module AutoDiffSource

export @δ, checkdiff, checkgrad

export δplus, δminus, δtimes, δdivide, δabs, δsum, δsqrt, δexp, δlog, δpower, δsign
export δdotplus, δdotminus, δdottimes, δdotdivide, δdotabs, δdotsqrt, δdotexp, δdotlog, δdotpower, δdotsign
export δplus_1, δminus_1, δtimes_1, δdivide_1, δpower_1
export δdotplus_1, δdotminus_1, δdottimes_1, δdotdivide_1, δdotpower_1
export δplus_2, δminus_2, δtimes_2, δdivide_2, δpower_2
export δdotplus_2, δdotminus_2, δdottimes_2, δdotdivide_2, δdotpower_2
export δfanout

include("parse.jl")
include("diff.jl")
include("func.jl")
include("checkdiff.jl")

end
