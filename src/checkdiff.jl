function checkdiff(f, δf, x0...)
    x = [x0...]
    y0 = f(x...)
    @assert length(y0) == 1 "Scalar functions only"
    y, ∇f = δf(x...)
    if !isapprox(y0, y)
        #        @show "function values do not match"
        return false
    end
    ∂x = ∇f()

    h = 1e-8

    for k = 1:length(x)
        ∂xx = length(x) == 1 ? ∂x : ∂x[k]
        if isa(x[k], AbstractFloat)
            x2 = deepcopy(x)
            x2[k] -= h
            y1 = f(x2...)
            x2 = deepcopy(x)
            x2[k] += h
            y2 = f(x2...)
            if !isapprox(2h * ∂xx, y2-y1, atol=h)
                #                @show "gradient for argument #$k doesn't match"
                return false
            end
        elseif isa(x[k], AbstractVector)
            for l = 1:length(x[k])
                x2 = deepcopy(x)
                x2[k][l] -= h
                y1 = f(x2...)
                x2 = deepcopy(x)
                x2[k][l] += h
                y2 = f(x2...)
                if !isapprox(2h * ∂xx[l], y2-y1, atol=h)
                    #                    @show "gradient for argument #$k element $l doesn't match"
                    return false
                end
            end
        else
            error("not supported argument type: $(typeof(x[k]))")
        end
    end
    true
end
