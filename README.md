# AutoDiff


Automatically differentiate a function with a ```δ``` macro:
```
@δ ff(x, y) = (x + y) * y
```

That will generate both a regular function ```ff``` and a special ```δff``` function:
```
z1 = ff(x, y)
z2, ∇f = δff(x, y)
∂x, ∂y = ∇f()
```

Functions can be nested and corresponding ```δ``` functions are found by convention, multiple return values are supported too:
```
@δ function f(x, y) 
   q = ff(x * y, y) * x
   q + y, q - x
end
```

To calculate the value and get a closure to calculate the gradient just call a δ function:
```
z, t, ∇f = δf(x, y)
```

To calculate the gradient later, once partial derivates are known, just call the closure as a regular function:
```
∂x, ∂y = ∇f(∂z, ∂t)
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
