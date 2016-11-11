using AutoDiffSource
using Base.Test

function checkdiff_inferred(f, δf, x0...)
    x = [x0...]
    y0 = f(x...)
    @assert length(y0) == 1 "Scalar functions only"
    y, ∇f = Test.@inferred δf(x...)
    isapprox(y0, y) || error("function values do not match")
    ∂x = Test.@inferred ∇f()
    checkgrad(f, x, ∂x)
end

# check basic use
@δ f(x, y) = (x + y) * y
@test checkdiff(f, δf, 2., 3.)

# check numerical constants
@δ function f2(x, y::AbstractFloat)
    z = 2.5x - y^2
    z / y
end
@test checkdiff_inferred(f2, δf2, 2., 3.)

# test broadcast
@δ f3(x) = sum(abs.(x))
@test checkdiff_inferred(f3, δf3, rand(5)-0.5)

# test multi argument functions and reuse
@δ f4(x, y) =  x * y, x - y
@δ function f5(x)
    (a, b) = f4(x, x+3)
    a * x + 4b
end
@test checkdiff_inferred(f5, δf5, rand()-0.5)

# test external constants
const f6_const = rand(5)
@δ f6(x) = sum(f6_const .* x)
@test checkdiff_inferred(f6, δf6, rand(5))

# test ...
@δ function f7(x...)
    a, b = x
    a * b
end
@test checkdiff_inferred(f7, δf7, rand(2)...)

# test ...
@δ function f8(x...)
    a, b, c, d, e, f, g, h, i, j, k, l, m, n = x
    a * b + c * d - e * f + g * h - i * j / k * l + m * n
end
@test checkdiff_inferred(f8, δf8, rand(14)...)

# test matrix multiply
@δ f9(x, y) = sum(x * y)
@test checkdiff_inferred(f9, δf9, rand(3), rand(3)')
@test checkdiff_inferred(f9, δf9, rand(3)', rand(3))
@test checkdiff_inferred(f9, δf9, rand(3)', rand(3, 3))
@test checkdiff_inferred(f9, δf9, rand(3, 3), rand(3))
@test checkdiff_inferred(f9, δf9, rand(3, 3), rand(3, 3))

# test sequence of plus and times
@δ f10(x, y, z) = (x + y + z) * x * y * z
@test checkdiff_inferred(f10, δf10, rand(), rand(), rand())

# (scalar, scalar), (scalar, const), (const, scalar)
for o in [:+, :-, :*, :/, :^]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = $o(x, y)
    @eval @test checkdiff_inferred($t, $δt, rand(), rand())
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = $o(x, 2.)
    @eval @test checkdiff_inferred($t, $δt, rand())
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = $o(2., x)
    @eval @test checkdiff_inferred($t, $δt, rand())
end

# (scalar)
for o in [:abs, :sum, :sqrt, :exp, :log, :-, :sign, :log1p, :expm1,
          :sin, :cos, :tan, :sinh, :cosh, :tanh, :asin, :acos, :atan,
          :round, :floor, :ceil, :trunc, :mod2pi, :maximum, :minimum, :transpose,
          :erf, :erfc, :gamma, :lgamma]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = $o(x)
    @eval @test checkdiff_inferred($t, $δt, rand())
end

# (vector, vector), (matrix, matrix), (const, *), (*, const)
# (vector, matrix), (matrix, vector), (vector, scalar), (matrix, scalar), (scalar, vector), (scalar, matrix)
for o in [:.+, :.-, :.*, :./, :.^]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = sum($o(x, y))
    @eval @test checkdiff_inferred($t, $δt, rand(5), rand(5))
    @eval @test checkdiff_inferred($t, $δt, rand(3, 2), rand(3, 2))

    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o(x, 3.))
    @eval @test checkdiff_inferred($t, $δt, rand())
    @eval @test checkdiff_inferred($t, $δt, rand(5))
    @eval @test checkdiff_inferred($t, $δt, rand(3, 2))

    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o(3., x))
    @eval @test checkdiff_inferred($t, $δt, rand())
    @eval @test checkdiff_inferred($t, $δt, rand(5))
    @eval @test checkdiff_inferred($t, $δt, rand(3, 2))

    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = sum($o(x, y))
    @eval @test checkdiff_inferred($t, $δt, rand(3), rand(3, 2))
    @eval @test checkdiff_inferred($t, $δt, rand(3, 2), rand(3))
    @eval @test checkdiff_inferred($t, $δt, rand(5), rand())
    @eval @test checkdiff_inferred($t, $δt, rand(3, 2), rand())
    @eval @test checkdiff_inferred($t, $δt, rand(), rand(5))
    @eval @test checkdiff_inferred($t, $δt, rand(), rand(3, 2))
end

# (vector), (matrix)
for o in [:abs, :sqrt, :exp, :log, :sign, :log1p, :expm1,
          :sin, :cos, :tan, :sinh, :cosh, :tanh, :asin, :acos, :atan,
          :round, :floor, :ceil, :trunc, :mod2pi,
          :erf, :erfc, :gamma, :lgamma]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o.(x))
    @eval @test checkdiff_inferred($t, $δt, rand(5))
    @eval @test checkdiff_inferred($t, $δt, rand(3, 2))
end

# (vector, scalar), (matrix, scalar), (scalar, vector), (scalar, matrix), (const, *), (*, const)
for o in [:+, :-, :*]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = sum($o(x, y))
    @eval @test checkdiff_inferred($t, $δt, rand(5), rand())
    @eval @test checkdiff_inferred($t, $δt, rand(3, 2), rand())
    @eval @test checkdiff_inferred($t, $δt, rand(), rand(5))
    @eval @test checkdiff_inferred($t, $δt, rand(), rand(3, 2))

    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o(x, 4.))
    @eval @test checkdiff_inferred($t, $δt, rand(5))
    @eval @test checkdiff_inferred($t, $δt, rand(3, 2))

    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o(5., x))
    @eval @test checkdiff_inferred($t, $δt, rand(5))
    @eval @test checkdiff_inferred($t, $δt, rand(3, 2))
end

# (vector, scalar), (matrix, scalar), (*, const)
for o in [:/]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = sum($o(x, y))
    @eval @test checkdiff_inferred($t, $δt, rand(5), rand())
    @eval @test checkdiff_inferred($t, $δt, rand(3, 2), rand())

    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o(x, 5.))
    @eval @test checkdiff_inferred($t, $δt, rand(5))
    @eval @test checkdiff_inferred($t, $δt, rand(3, 2))
end

for o in [:dot]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = $o(x, y)
    @eval @test checkdiff_inferred($t, $δt, rand(5), rand(5))
    @eval @test checkdiff_inferred($t, $δt, rand(3, 2), rand(3, 2))
end

for o in [:transpose, :maximum, :minimum]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o(x))
    @eval @test checkdiff_inferred($t, $δt, rand(5))
    @eval @test checkdiff_inferred($t, $δt, rand(3, 2))
end
