using AutoDiffSource
using BenchmarkTools

@δ rosenbrock(x, y) = sum(100*(y-x.^2).^2 + (1-x).^2)
@δ rosenbrock(x) = rosenbrock(x[1:length(x)-1], x[2:length(x)])

# verify correctness
@assert checkdiff(rosenbrock, δrosenbrock, randn(3))

# handcrafted derivative
function ∇rosenbrock(x)
    x1 = x[1:end-1]
    x2 = x[2:end]
    ∂x = similar(x)
    ∂x[1:end-1] = - 400*x1.*(x2-x1.^2) - 2*(1-x1)
    ∂x[end] = 0
    ∂x[2:end] += 200*(x2-x1.^2)
    ∂x
end

# verify that it is correct
const x0 = randn(3)
@assert checkgrad(rosenbrock, (x0,), ∇rosenbrock(x0))

# benchmark
const x1 = randn(1_000)
trial1 = @benchmark (rosenbrock(x1), ∇rosenbrock(x1));
trial2 = @benchmark ((y, ∇r) = δrosenbrock(x1); ∇r())

# auto should be ~15% faster than handcrafted
trial1, trial2
