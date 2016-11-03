function checkdiff(f, δf, x0...)
    x = [x0...]
    y0 = f(x...)
    @assert length(y0) == 1 "Scalar functions only"
    y, ∇f = δf(x...)
    if !isapprox(y0, y)
        @show "function values do not match"
        return false
    end
    ∂x = ∇f()

    h = 1e-8

    for k = 1:length(x)
        if isa(x[k], AbstractFloat)
            x2 = deepcopy(x)
            x2[k] -= h
            y1 = f(x2...)
            x2 = deepcopy(x)
            x2[k] += h
            y2 = f(x2...)
            if !isapprox(2h * ∂x[k], y2-y1, atol=h)
                @show "gradient for argument #$k doesn't match"
                return false
            end
        else
            error("not supported argument type: $(typeof(x[k]))")
        end
    end
    true
end
