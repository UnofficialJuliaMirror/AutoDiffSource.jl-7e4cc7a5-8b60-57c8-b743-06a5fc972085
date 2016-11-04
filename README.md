# AutoDiff

Automatically differentiate a function with a ```δ``` macro:
```
@δ f(x, y) = (x + y) * y
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

| master (on nightly + release) | Coverage |
|:-----------------------------:|:-----------:|
|[![Build Status](https://travis-ci.org/gaika/AutoDiff.jl.svg?branch=master)](https://travis-ci.org/gaika/AutoDiff.jl) | [![Coverage Status](https://coveralls.io/repos/github/gaika/AutoDiff.jl/badge.svg?branch=master)](https://coveralls.io/github/gaika/AutoDiff.jl?branch=master) |
