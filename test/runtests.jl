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

const ops = [:+, :-, :*, :/, :^]
const oneargs = [:abs, :sum, :sqrt, :exp, :log]
const dotops = [:.+, :.-, :.*, :./, :.^]
const dotoneargs = [:abs, :sqrt, :exp, :log]
const mixedops = [:+, :-, :*, :/, :^, :.+, :.-, :.*, :./, :.^]

for o in oneargs
    t = gensym(o)
    δt = Symbol("δ$t")
    @eval @δ $t(x) = $o(x)
    @eval @test checkdiff($t, $δt, rand())
end
