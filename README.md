# AutoDiffSource

Automatic differentiation with source code transformation in Julia (reverse mode)

[![Build Status](https://travis-ci.org/gaika/AutoDiffSource.jl.svg?branch=master)](https://travis-ci.org/gaika/AutoDiffSource.jl)
[![Coverage Status](https://coveralls.io/repos/github/gaika/AutoDiffSource.jl/badge.svg?branch=master)](https://coveralls.io/github/gaika/AutoDiffSource.jl?branch=master)
[![codecov](https://codecov.io/gh/gaika/AutoDiffSource.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/gaika/AutoDiffSource.jl)

Install:
```
Pkg.add("AutoDiffSource")
using AutoDiffSource
```

Differentiate a function with a ```δ``` macro:
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
@δ function ff(x, y)
   q = f(x * y, y) * x
   q + y, q - x
end
```

To calculate the value and get a closure to calculate the gradient just call a δ function:
```
z, t, ∇ff = δff(x, y)
```

To calculate the gradient later, once partial derivates are known, just call the closure as a regular function:
```
∂x, ∂y = ∇ff(∂z, ∂t)
```

You can define a function with your own gradient calculations:
```
div(x, y) = x / y
δdiv(x, y) = (x/y, z -> (z/y, -z*x/y^2))
```

Can be used as a building block for other functions:
```
@δ fff(x, y) = div(x, y) + y
```

If you have external constants that you don't need to differentiate:
```
const c = rand(10)
@δ ffff(x) = sum(c .* x)
```

### Similar efforts

https://github.com/JuliaDiff/ReverseDiffSource.jl is pretty close and has more features. This one is faster, easier to use, supports multiple return values, and since forward and backward passes are separate it can differentiate nested functions or be plugged in to your own gradient learning code with ease.
