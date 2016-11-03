macro δ(expr)
    esc(:( $expr; $(δ(parse_function(expr); ))))
end

function δ(ops)
    name = Symbol("δ$(ops.name)")
    func = :(function $name($(ops.inputs...)); end)
    body = func.args[2].args
    empty!(body)
    info = Expr(:line)
    nablas = []
    for line in ops.body
        if info != line.info
            info = line.info
            push!(body, info)
        end
        nabla = gensym("∇$(line.name)")
        push!(nablas, nabla)
        name = Symbol("δ$(line.name)")
        temp = gensym(name)
        push!(body, :($temp = $name($(line.inputs...))))
        for k in 1:length(line.outputs)
            push!(body, :($(line.outputs[k]) = $temp[$k]))
        end
        push!(body, :($nabla = $temp[$(length(line.outputs)+1)]))
    end
    push!(body, ∇(ops, nablas))
    push!(body, :($(ops.outputs...), $(Symbol("∇$(ops.name)"))))
    @show func
    func
end

function ∇(ops, nablas)
    name = Symbol("∇$(ops.name)")
    inputs =  [Symbol("∂$x") for x in ops.outputs]
    func = :(function $name($(inputs...)); end)
    body = func.args[2].args
    empty!(body)
    info = Expr(:line)
    dupes = Set(inputs)
    for line in reverse(ops.body)
        if info != line.info
            info = line.info
            push!(body, info)
        end
        nabla = pop!(nablas)
        ins = [Symbol("∂$x") for x in line.outputs]
        outs = [Symbol("∂$x") for x in line.inputs]
        dedup = [in(k, dupes)? gensym(k) : (push!(dupes, k); k) for k in outs]
        push!(body, :($(to_tuple_or_expr(dedup)) = $nabla($(ins...))))
        for k in 1:length(outs)
            if outs[k] != dedup[k]
                push!(body, :($(outs[k]) += $(dedup[k])))
            end
        end
    end

    outputs = [Symbol("∂$x") for x in ops.inputs]
    push!(body, to_tuple_or_expr(outputs))
    func
end

to_tuple_or_expr(o) = length(o) == 1 ? o[1] : Expr(:tuple, o...)
