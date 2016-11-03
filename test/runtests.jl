using AutoDiff
using Base.Test

@δ f(x, y) = (x + y) * y

@test checkgrad(f, δf, 2., 3.)

@δ function f2(x, y)
    (x - y) / y
end

@test checkgrad(f2, δf2, 2., 3.)

