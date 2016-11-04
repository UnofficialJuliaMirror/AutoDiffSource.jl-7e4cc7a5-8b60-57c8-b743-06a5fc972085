using AutoDiffSource
using Base.Test

@δ f(x, y) = (x + y) * y

@test checkdiff(f, δf, 2., 3.)

@δ function f2(x, y::AbstractFloat)
    z = x - y
    z / y
end

@test checkdiff(f2, δf2, 2., 3.)

@δ f3(x) = sum(abs.(x))

@test checkdiff(f3, δf3, rand(5)-0.5)

# (scalar, scalar)
for o in [:+, :-, :*, :/, :^]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = $o(x, y)
    @eval @test checkdiff($t, $δt, rand(), rand())
end

# (scalar)
for o in [:abs, :sum, :sqrt, :exp, :log, :-]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = $o(x)
    @eval @test checkdiff($t, $δt, rand())
end

# (vector, vector), (matrix, matrix)
for o in [:.+, :.-, :.*, :./, :.^]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = sum($o(x, y))
    @eval @test checkdiff($t, $δt, rand(5), rand(5))
    @eval @test checkdiff($t, $δt, rand(3, 2), rand(3, 2))
end

# (vector), (matrix)
for o in [:abs, :sqrt, :exp, :log]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = sum($o.(x))
    @eval @test checkdiff($t, $δt, rand(5))
    @eval @test checkdiff($t, $δt, rand(3, 2))
end

# (vector, scalar), (matrix, scalar), (scalar, vector), (scalar, matrix)
for o in [:+, :-, :*]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = sum($o(x, y))
    @eval @test checkdiff($t, $δt, rand(5), rand())
    @eval @test checkdiff($t, $δt, rand(3, 2), rand())
    @eval @test checkdiff($t, $δt, rand(), rand(5))
    @eval @test checkdiff($t, $δt, rand(), rand(3, 2))
end

# (vector, scalar), (matrix, scalar)
for o in [:/]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = sum($o(x, y))
    @eval @test checkdiff($t, $δt, rand(5), rand())
    @eval @test checkdiff($t, $δt, rand(3, 2), rand())
end

# (vector, matrix), (matrix, vector), (vector, scalar), (matrix, scalar), (scalar, vector), (scalar, matrix)
for o in [:.+, :.-, :.*, :./, :.^]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = sum($o(x, y))
    @eval @test checkdiff($t, $δt, rand(3), rand(3, 2))
    @eval @test checkdiff($t, $δt, rand(3, 2), rand(3))
    @eval @test checkdiff($t, $δt, rand(5), rand())
    @eval @test checkdiff($t, $δt, rand(3, 2), rand())
    @eval @test checkdiff($t, $δt, rand(), rand(5))
    @eval @test checkdiff($t, $δt, rand(), rand(3, 2))
end
