__precompile__()
module AutoDiffSource

export @δ, @delta, checkdiff, checkgrad

export δplus, δminus, δtimes, δdivide, δabs, δsum, δsqrt, δexp, δlog, δpower, δsign, δdot
export δdot_plus, δdot_minus, δdot_times, δdot_divide, δdot_abs, δdot_sqrt, δdot_exp, δdot_log, δdot_power, δdot_sign
export δplus_const1, δminus_const1, δtimes_const1, δdivide_const1, δpower_const1
export δdot_plus_const1, δdot_minus_const1, δdot_times_const1, δdot_divide_const1, δdot_power_const1
export δplus_const2, δminus_const2, δtimes_const2, δdivide_const2, δpower_const2
export δdot_plus_const2, δdot_minus_const2, δdot_times_const2, δdot_divide_const2, δdot_power_const2
export δfanout
export δsrand_const, δrand_const, δrandn_const, δsize_const

export δlog1p, δexpm1, δsin, δcos, δtan, δsinh, δcosh, δtanh, δasin, δacos, δatan
export δround, δfloor, δceil, δtrunc, δmod2pi, δmaximum, δminimum, δtranspose
export δerf, δerfc, δgamma, δlgamma, δmin, δmax, δmin_const1, δmax_const1, δmin_const2, δmax_const2

export δdot_log1p, δdot_expm1, δdot_sin, δdot_cos, δdot_tan, δdot_sinh, δdot_cosh, δdot_tanh, δdot_asin, δdot_acos, δdot_atan
export δdot_round, δdot_floor, δdot_ceil, δdot_trunc, δdot_mod2pi, δdot_transpose
export δdot_erf, δdot_erfc, δdot_gamma, δdot_lgamma, δdot_min, δdot_max
export δdot_min_const1, δdot_max_const1, δdot_min_const2, δdot_max_const2

include("parse.jl")
include("diff.jl")
include("func.jl")
include("checkdiff.jl")

end
