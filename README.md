# AutoDiffSource

Automatic differentiation with source code transformation in Julia (reverse mode)

[![AutoDiffSource](http://pkg.julialang.org/badges/AutoDiffSource_0.5.svg)](http://pkg.julialang.org/?pkg=AutoDiffSource)
[![AutoDiffSource](http://pkg.julialang.org/badges/AutoDiffSource_0.6.svg)](http://pkg.julialang.org/?pkg=AutoDiffSource)
[![Build Status](https://travis-ci.org/gaika/AutoDiffSource.jl.svg?branch=master)](https://travis-ci.org/gaika/AutoDiffSource.jl)
[![Coverage Status](https://coveralls.io/repos/github/gaika/AutoDiffSource.jl/badge.svg?branch=master)](https://coveralls.io/github/gaika/AutoDiffSource.jl?branch=master)
[![codecov](https://codecov.io/gh/gaika/AutoDiffSource.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/gaika/AutoDiffSource.jl)

### Install (requires Julia v0.5):
```
Pkg.add("AutoDiffSource") 
# Pkg.checkout("AutoDiffSource") # To stay on top of development releases
using AutoDiffSource
```

### Differentiate a function with ```@δ``` macro:
```
@δ f(x, y) = (x + 2y) * y^2
```

That will generate both a regular function ```f``` and a special ```δf``` function:
```
z, ∇f = δf(x, y)
∂x, ∂y = ∇f()
```

Functions can be nested and corresponding ```δ``` functions are found by convention, multiple return values are supported too:
```
@δ function f2(x, y)
   q = f(x * y, y) * x
   q + y, q - x
end
```

To calculate the value and get a closure function for the gradient:
```
z, t, ∇f2 = δf2(x, y)
```

To calculate the gradient later, once partial derivates are known, just call the closure as a regular function:
```
∂x, ∂y = ∇f2(∂z, ∂t)
```

You can define a function with your own gradient calculations:
```
div(x, y) = x / y
δdiv(x, y) = (x/y, z -> (z/y, -z*x/y^2))
```

Can be used as a building block for other functions:
```
@δ f3(x, y) = div(x, y) + y
```

If you have external constants that you don't need to differentiate:
```
const c = rand(10)
@δ f4(x) = sum(c .* x)
```

[Example](https://github.com/gaika/AutoDiffSource.jl/blob/master/examples/mnist_autoencoder.jl) from training an [autoencoder NN](http://int8.io/automatic-differentiation-machine-learning-julia/):
```
@δ function sigmoid(x)
    t = exp.(-x)
    1 ./ (1 + t)
end
@δ function autoencoderError(We1, We2 , Wd, b1, b2,  input)
    firstLayer = sigmoid(We1 * input .+ b1)
    encodedInput = sigmoid(We2 * firstLayer .+ b2)
    reconstructedInput = sigmoid(Wd * encodedInput)
    sum((input .- reconstructedInput).^2)
end
@assert checkdiff(autoencoderError, δautoencoderError, randn(3,3), randn(3,3), rand(3,3), randn(3), randn(3), randn(3))
value, ∇autoencoderError = δautoencoderError(We1, We2, Wd, b1, b2, input)
∂We1, ∂We2, ∂Wd, ∂b1, ∂b2 = ∇autoencoderError()
```

### Comparison to similar efforts

[ReverseDiffSource](https://github.com/JuliaDiff/ReverseDiffSource.jl) is pretty close and has more features. This one is faster, easier to use, and supports functions with multiple return values. Since forward and backward passes are separate it can differentiate nested functions or be plugged in to your own gradient learning code.

