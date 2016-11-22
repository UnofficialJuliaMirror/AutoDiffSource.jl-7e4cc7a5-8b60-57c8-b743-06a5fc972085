__precompile__()
module AutoDiffSource

export @δ, checkdiff, checkgrad

export δplus, δminus, δtimes, δdivide, δabs, δsum, δsqrt, δexp, δlog, δpower, δdot
export δdot_plus, δdot_minus, δdot_times, δdot_divide, δdot_abs, δdot_sqrt, δdot_exp, δdot_log, δdot_power
export δplus_const1, δminus_const1, δtimes_const1, δdivide_const1, δpower_const1
export δdot_plus_const1, δdot_minus_const1, δdot_times_const1, δdot_divide_const1, δdot_power_const1
export δplus_const2, δminus_const2, δtimes_const2, δdivide_const2, δpower_const2
export δdot_plus_const2, δdot_minus_const2, δdot_times_const2, δdot_divide_const2, δdot_power_const2
export δfanout, δzeros, δzeros_const, δones_const, δlength_const, δcolon_const
export δsrand_const, δrand_const, δrandn_const, δsize_const, δsign_const

export δlog1p, δexpm1, δsin, δcos, δtan, δsinh, δcosh, δtanh, δasin, δacos, δatan
export δround_const, δfloor_const, δceil_const, δtrunc_const, δmod2pi, δmaximum, δminimum, δtranspose
export δerf, δerfc, δgamma, δlgamma, δmin, δmax, δmin_const1, δmax_const1, δmin_const2, δmax_const2

export δdot_log1p, δdot_expm1, δdot_sin, δdot_cos, δdot_tan, δdot_sinh, δdot_cosh, δdot_tanh, δdot_asin, δdot_acos, δdot_atan
export δdot_round_const, δdot_floor_const, δdot_ceil_const, δdot_trunc_const, δdot_mod2pi, δdot_transpose
export δdot_erf, δdot_erfc, δdot_gamma, δdot_lgamma, δdot_min, δdot_max
export δdot_min_const1, δdot_max_const1, δdot_min_const2, δdot_max_const2

export dot_times, times, dot_plus, plus, dot_divide, divide, dot_minus, minus, dot_power, power

include("parse.jl")
include("diff.jl")
include("func.jl")
include("checkdiff.jl")

macro δ(expr::Expr)
    esc(:( $expr; $(δ(macroexpand(expr)))))
end

macro δ(f::Symbol)
    fs = methods(eval(GlobalRef(Main, f)))
    length(fs) >  0 || error("function '$f' not found")
    expr = Expr(:block)
    for fdef in fs.ms
        fn = VERSION >= v"0.6.0-" ? Base.uncompressed_ast(fdef, fdef.source).code : Base.uncompressed_ast(fdef.lambda_template)
        fcode = fn[2:end]
        types = getfield(fdef.sig, 3)
        fargs = [Expr(:(::), Symbol("_$i"), types[i]) for i in 2:length(types)]
        fname = Symbol(string(f))
        func = :(function $fname($(fargs...)); end)
        body = func.args[2].args
        empty!(body)
        foreach(arg -> push!(body, arg), fcode)
        push!(expr.args, δ(func))
    end
    esc(expr)
end

function δ(expr)
    delta(parse_function(expr))
end

end
