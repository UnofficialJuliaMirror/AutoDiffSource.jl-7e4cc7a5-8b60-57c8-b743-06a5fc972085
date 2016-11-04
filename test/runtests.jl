using AutoDiff
using Base.Test

@δ f(x, y) = (x + y) * y

@test checkdiff(f, δf, 2., 3.)

@δ function f2(x, y::AbstractFloat)
    z = x - y
    z / y
end

@test checkdiff(f2, δf2, 2., 3.)

@δ f3(x) = sum(abs.(x))

@test checkdiff(f3, δf3, rand(100)-0.5)

for o in [:+, :-, :*, :/, :^]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = $o(x, y)
    @eval @test checkdiff($t, $δt, rand(), rand())
end

for o in [:abs, :sum, :sqrt, :exp, :log]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = $o(x)
    @eval @test checkdiff($t, $δt, rand())
end

for o in [:.+, :.-, :.*, :./, :.^]
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x, y) = sum($o(x, y))
    @eval @test checkdiff($t, $δt, rand(10), rand(10))
    @eval @test checkdiff($t, $δt, rand(3, 4), rand(3, 4))
end

for o in [:abs, :sqrt, :exp, :log]
end

for o in [:+, :-, :*, :/, :^, :.+, :.-, :.*, :./, :.^]
end
