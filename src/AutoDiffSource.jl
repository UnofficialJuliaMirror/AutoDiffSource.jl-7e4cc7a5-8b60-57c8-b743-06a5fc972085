__precompile__()
module AutoDiffSource

export @δ, checkdiff, checkgrad

export δplus, δminus, δtimes, δdivide, δabs, δsum, δsqrt, δexp, δlog, δpower, δsign, δdot
export δdot_plus, δdot_minus, δdot_times, δdot_divide, δdot_abs, δdot_sqrt, δdot_exp, δdot_log, δdot_power, δdot_sign
export δplus_1, δminus_1, δtimes_1, δdivide_1, δpower_1
export δdot_plus_1, δdot_minus_1, δdot_times_1, δdot_divide_1, δdot_power_1
export δplus_2, δminus_2, δtimes_2, δdivide_2, δpower_2
export δdot_plus_2, δdot_minus_2, δdot_times_2, δdot_divide_2, δdot_power_2
export δfanout

export δlog1p, δexpm1, δsin, δcos, δtan, δsinh, δcosh, δtanh, δasin, δacos, δatan
export δround, δfloor, δceil, δtrunc, δmod2pi, δmaximum, δminimum, δtranspose
export δerf, δerfc, δgamma, δlgamma, δmin, δmax, δmin_1, δmax_1, δmin_2, δmax_2

export δdot_log1p, δdot_expm1, δdot_sin, δdot_cos, δdot_tan, δdot_sinh, δdot_cosh, δdot_tanh, δdot_asin, δdot_acos, δdot_atan
export δdot_round, δdot_floor, δdot_ceil, δdot_trunc, δdot_mod2pi, δdot_transpose
export δdot_erf, δdot_erfc, δdot_gamma, δdot_lgamma, δdot_min, δdot_max, δdot_min_1, δdot_max_1, δdot_min_2, δdot_max_2

include("parse.jl")
include("diff.jl")
include("func.jl")
include("checkdiff.jl")

end
