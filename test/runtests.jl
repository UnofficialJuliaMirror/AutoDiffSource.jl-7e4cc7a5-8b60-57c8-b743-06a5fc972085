using AutoDiff
using Base.Test

@δ f(x, y) = (x + y) * y

@test checkdiff(f, δf, 2., 3.)

@δ function f2(x, y)
    (x - y) / y
end

@test checkdiff(f2, δf2, 2., 3.)
