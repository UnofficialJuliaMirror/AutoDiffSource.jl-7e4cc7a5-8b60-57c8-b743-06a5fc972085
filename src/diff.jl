macro δ(expr)
    esc(:( $expr; $(δ(parse_function(expr); ))))
end

function δ(ops)
    name = Symbol("δ$(ops.name)")
    func = :(function $name($(ops.inputs...)); end)
    body = func.args[2].args
    empty!(body)
    info = Expr(:line)
    for line in ops.body
        if info != line.info
            info = line.info
            push!(body, info)
        end
        nabla = Symbol("∇$(line.name)_$(line.outputs[1])")
        name = Symbol("δ$(line.name)")
        push!(body, :(($(line.outputs...), $nabla) = $name($(line.inputs...))))
    end
    push!(body, ∇(ops))
    push!(body, :($(ops.outputs...), $(Symbol("∇$(ops.name)"))))
    @show func
    func
end

function ∇(ops)
end
