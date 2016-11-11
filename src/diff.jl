macro δ(expr)
    esc(:( $expr; $(δ(parse_function(macroexpand(expr)); ))))
end

isvar(n::Number) = false
isvar(n::Symbol) = true

function δ(ops)
    name = Symbol("δ$(ops.name)")
    func = :(function $name($(ops.inputs...)); end)
    body = func.args[2].args
    empty!(body)
    nablas = []
    last_info = [Expr(:line)]
    for line in ops.body
        push_if_changed!(body, last_info, line.info)
        name = string(line.name)
        for k = eachindex(line.inputs)
            if !isvar(line.inputs[k])
                name *= "_$k"
            end
        end
        nabla = gensym("∇" * name)
        push!(nablas, nabla)
        name = Symbol("δ" * name)
        temp = gensym(name)
        # push!(body, :(($(line.outputs...), $nabla) = $name($(line.inputs...)))),
        # work around for https://github.com/JuliaLang/julia/issues/15276
        push!(body, :($temp = $name($(line.inputs...))))
        [push!(body, :($(line.outputs[k]) = $temp[$k])) for k in 1:length(line.outputs)]
        push!(body, :($nabla = $temp[$(length(line.outputs)+1)]))
        # end work around
    end
    push!(body, ∇(ops, nablas))
    push!(body, :($(ops.outputs...), $(Symbol("∇$(ops.name)"))))
    #    @show func
    func
end

function ∇(ops, nablas)
    name = Symbol("∇$(ops.name)")
    inputs = map(topartial, ops.outputs)
    func = :(function $name($(inputs...)); end)
    if length(inputs) == 1
        func.args[1].args[2] = Expr(:kw, func.args[1].args[2], 1f0)
    end
    body = func.args[2].args
    empty!(body)
    dupes = Set(inputs)
    last_info = [Expr(:line)]
    for line in reverse(ops.body)
        push_if_changed!(body, last_info, line.info)
        nabla = pop!(nablas)
        ins = map(topartial, line.outputs)
        outs = map(topartial, filter(isvar, line.inputs))
        dedup = [in(k, dupes)? gensym(k) : (push!(dupes, k); k) for k in outs]
        push!(body, :($(toexpr(dedup)) = $nabla($(ins...))))
        [push!(body, :($(outs[k]) += $(dedup[k]))) for k in find(outs .!= dedup)]
    end
    push!(body, toexpr(map(topartial, ops.inputs)))
    func
end

topartial(expr::Symbol) = Symbol("∂$expr")
topartial(expr::Expr) = Symbol("∂$(expr.args[1])")
toexpr(symbols) = length(symbols) == 1 ? symbols[1] : Expr(:tuple, symbols...)

function push_if_changed!(body, last_info, info)
    if last_info[1] != info
        last_info[1] = info
        push!(body, info)
    end
end
