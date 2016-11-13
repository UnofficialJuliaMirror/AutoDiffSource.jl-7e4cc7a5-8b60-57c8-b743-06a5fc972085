macro δ(expr)
    esc(:( $expr; $(δ(parse_function(macroexpand(expr)); ))))
end

macro delta(expr)
    esc(:( $expr; $(δ(parse_function(macroexpand(expr)); ))))
end

isvar(n::Number) = false
isvar(n::Symbol) = !endswith(string(n), "_const")
isvar(n::Expr) = n.head == :(::) ? isvar(n.args[1]) : true
isconst(n) = !isvar(n)

const reversenames = Dict(:times => :(*), :plus => :(+), :divide => :(/), :minus => :(-), :power => :(^))

function δ(ops)
    funcname = Symbol("δ$(ops.name)")
    func = :(function $funcname($(ops.inputs...)); end)
    body = func.args[2].args
    empty!(body)
    nablas = Dict{Op,Symbol}()
    last_info = [Expr(:line)]
    for line in ops.body
        push_if_changed!(body, last_info, line.info)
        name = replace(string(line.name), "dot_", "")
        constname = Symbol("δ$(name)_const")
        if isdefined(constname) || all(isconst, line.inputs) || all(isconst, line.outputs)
            sname = Symbol(name)
            sname = get(reversenames, sname, sname)
            if sname == :fanout
                temp = gensym(name)
                push!(body, :($temp = $(line.inputs...)))
                [push!(body, :($(line.outputs[k]) = $temp[$k])) for k in 1:length(line.outputs)]
            elseif startswith(string(line.name), "dot_")
                push!(body, :($(toexpr(line.outputs)) = $sname.($(line.inputs...))))
            else
                push!(body, :($(toexpr(line.outputs)) = $sname($(line.inputs...))))
            end
        else
            name = string(line.name)
            nabla = gensym("∇" * name)
            nablas[line] = nabla
            temp = gensym(name)
            funcname = Symbol("δ" * name)
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
    #    @show func
    func
end

function ∇(ops, nablas)
    name = Symbol("∇$(ops.name)")
    inputs = map(topartial, filter(isvar, ops.outputs))
    func = :(function $name($(inputs...)); end)
    if length(inputs) == 1
        func.args[1].args[2] = Expr(:kw, func.args[1].args[2], 1f0)
    end
    body = func.args[2].args
    empty!(body)
    dupes = Set(inputs)
    emptys = Set()
    last_info = [Expr(:line)]
    for line in reverse(ops.body)
        push_if_changed!(body, last_info, line.info)
        if haskey(nablas, line)
            nabla = nablas[line]
            ins = map(topartial, filter(isvar, line.outputs))
            outs = map(topartial, filter(isvar, line.inputs))
            if length(outs) > 0
                for o in filter(isvar, line.outputs)
                    op = topartial(o)
                    if op ∈ emptys && op ∉ dupes
                        [push!(body, :($op = δzeros($o)))]
                    end
                end
                dedup = [k ∈ dupes ? gensym(k) : (push!(dupes, k); k) for k in outs]
                push!(body, :($(toexpr(dedup)) = $nabla($(ins...))))
                [push!(body, :($(outs[k]) += $(dedup[k]))) for k in find(outs .!= dedup)]
            end
        else
            foreach(o -> push!(emptys, topartial(o)), filter(isvar, line.inputs))
        end
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
