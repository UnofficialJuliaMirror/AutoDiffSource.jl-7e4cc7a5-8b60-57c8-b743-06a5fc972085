using AutoDiffSource
using BenchmarkTools

@δ rosenbrock(x, y) = sum(100*(y-x.^2).^2 + (1-x).^2)
rosenbrock(x) = rosenbrock(x[1:end-1], x[2:end])

# handcrafted derivative
function ∇rosenbrock(x)
    df = similar(x)
    df[1:end-1] = - 400*x[1:end-1].*(x[2:end]-x[1:end-1].^2) - 2*(1-x[1:end-1])
    df[end] = 0
    df[2:end] += 200*(x[2:end]-x[1:end-1].^2)
    df
end

# verify that it is correct
const x0 = randn(3)
@assert checkgrad(rosenbrock, (x0,), ∇rosenbrock(x0))

# automatic derivative (sorry, no array indexing yet)
function δrosenbrock(x)
    y, ∇rosenbrock = δrosenbrock(x[1:end-1], x[2:end])
    y, function ∇r(z = 1)
        (∂x1, ∂x2) = ∇rosenbrock(z)
        ∂x = similar(x)
        ∂x[1:end-1] = ∂x1
        ∂x[end] = 0
        ∂x[2:end] += ∂x2
        ∂x
    end
end

# verify correctness
@assert checkdiff(rosenbrock, δrosenbrock, randn(3))

const x1 = randn(1_000)
trial1 = @benchmark (rosenbrock(x1), ∇rosenbrock(x1));
trial2 = @benchmark ((y, ∇r) = δrosenbrock(x1); ∇r())

# auto should be ~20% faster than handcrafted
trial1, trial2
