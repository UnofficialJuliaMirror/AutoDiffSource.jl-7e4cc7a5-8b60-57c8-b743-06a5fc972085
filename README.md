# AutoDiff


auto diff a function
```
@δ f(x, y) = (x + y) * y
```

calculate the value and get the gradient callback function
```
z, ∇f = δf(x, y)
```

calculate the gradient
```
∂x, ∂y = ∇f(∂z)
```

define a custom function
```
δdivide(x, y) = (x/y, z-> (z/y, -z*x/y^2))
```
