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
        # push!(body, :(global $nabla)) # work around for https://github.com/JuliaLang/julia/issues/15276
        push!(nablas, nabla)
        name = Symbol("δ$(line.name)")
        push!(body, :(($(line.outputs...), $nabla) = $name($(line.inputs...))))
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
    partials = Set(inputs)
    temp = 1
    for line in reverse(ops.body)
        if info != line.info
            info = line.info
            push!(body, info)
        end
        nabla = pop!(nablas)
        i = [Symbol("∂$x") for x in line.outputs]
        o = [Symbol("∂$x") for x in line.inputs]

        inter = intersect(partials, Set(o))
        if length(inter) > 0 # XXX or same variable is used twice in the inputs
            if length(o) == 1
                push!(body, :($(to_tuple_or_expr(o)) += $nabla($(i...))))
            else
                oo = copy(o)
                for k in 1:length(o)
                    if in(o[k], inter)
                        oo[k] = Symbol("temp$temp")
                        temp += 1
                    end
                end
                push!(body, :($(to_tuple_or_expr(oo)) = $nabla($(i...))))
                for k in 1:length(o)
                    if in(o[k], inter)
                        push!(body, :($(o[k]) += $(oo[k])))
                    end
                end
            end
        else
            push!(body, :($(to_tuple_or_expr(o)) = $nabla($(i...))))
        end
        [push!(partials, e) for e in o]
    end

    outputs = [Symbol("∂$x") for x in ops.inputs]
    push!(body, to_tuple_or_expr(outputs))
    func
end

to_tuple_or_expr(o) = length(o) == 1 ? o[1] : Expr(:tuple, o...)
