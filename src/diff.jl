macro δ(expr)
    esc(:( $expr; $(δ(parse_function(macroexpand(expr)); ))))
end

macro delta(expr)
    esc(:( $expr; $(δ(parse_function(macroexpand(expr)); ))))
end

function name_of(line::Op)
    name = string(line.name)
    for k = eachindex(line.inputs)
        if isconst(line.inputs[k])
            name *= "_const$k"
        end
    end
    name
end

isconst(line::Op) = isconst(line.name) || all(isconst, line.outputs)

function δ(ops)
    funcname = Symbol("δ$(ops.name)")
    func = :(function $funcname($(ops.inputs...)); end)
    body = func.args[2].args
    empty!(body)
    nablas = []
    last_info = [Expr(:line)]
    for line in ops.body
        push_if_changed!(body, last_info, line.info)
        if isconst(line)
            funcname = Symbol(line.name)
            push!(body, :(($(line.outputs...)) = $funcname($(line.inputs...))))
        else
            name = name_of(line)
            nabla = gensym("∇" * name)
            push!(nablas, nabla)
            funcname = Symbol("δ" * name)
            temp = gensym(name)
            # push!(body, :(($(line.outputs...), $nabla) = $name($(line.inputs...)))),
            # work around for https://github.com/JuliaLang/julia/issues/15276
            push!(body, :($temp = $funcname($(line.inputs...))))
            [push!(body, :($(line.outputs[k]) = $temp[$k])) for k in 1:length(line.outputs)]
            push!(body, :($nabla = $temp[$(length(line.outputs)+1)]))
            # end work around
        end
    end
    push!(body, ∇(ops, nablas))
    push!(body, :($(ops.outputs...), $(Symbol("∇$(ops.name)"))))
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
        if isconst(line)
            continue
        end
        push_if_changed!(body, last_info, line.info)
        nabla = pop!(nablas)
        ins = map(topartial, line.outputs)
        outs = map(topartial, filter(isvar, line.inputs))
        dedup = [in(k, dupes)? gensym(k) : (push!(dupes, k); k) for k in outs]
        push!(body, :($(toexpr(dedup)) = $nabla($(ins...))))
        [push!(body, :($(outs[k]) += $(dedup[k]))) for k in find(outs .!= dedup)]
    end
    push!(body, toexpr(map(topartial, filter(isvar, ops.inputs))))
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
