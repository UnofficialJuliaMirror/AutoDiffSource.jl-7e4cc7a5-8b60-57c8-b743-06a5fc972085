type Op
    name::Symbol
    inputs::Vector
    outputs::Vector
    body::Vector
    info::Expr

    function Op(name, inputs, outputs, body, info, mapping = Dict{Symbol, Symbol}())
        if !isempty(body)
            remap = x -> get(mapping, x, x)
            uniques = Set{Symbol}()
            for op in body
                map!(remap, op.inputs)
                union!(uniques, filter(o->isa(o, Symbol), op.inputs))
                if isdefined(Symbol("δ$(op.name)_const")) || all(isconst, op.inputs)
                    [mapping[o] = Symbol("$(o)_const") for o in filter(isvar, op.outputs)]
                end
                [mapping[o] = gensym(o) for o in filter(o->o in inputs, op.outputs)]
                map!(remap, op.outputs)
                op.name = name_const(op.name, op.inputs, op.outputs)
            end
            map!(remap, outputs)
            name = name_const(name, inputs, outputs)
        end
        new(name, inputs, outputs, body, info)
    end
end

function name_const(name, inputs, outputs)
    if isdefined(Symbol("δ$(name)_const")) || all(isconst, inputs) || all(isvar, inputs) || all(isconst, outputs)
        return name
    end
    n = string(name)
    for k = eachindex(inputs)
        if !isvar(inputs[k])
            n *= "_const$k"
        end
    end
    Symbol(n)
end

function parse_function(expr, mapping = Dict{Symbol, Symbol}())
    @assert (expr.head == :function || expr.head == :(=)) && length(expr.args) == 2  "Only functions can be differentiated"
    header = expr.args[1]
    @assert header.head == :call "Only functions can be differentiated"
    name = header.args[1]
    inputs = header.args[2:end]
    body = expr.args[2]
    @assert body.head == :block "Body of the function is not found"

    ops = []
    outputs = []
    info = Expr(:line)

    for line in body.args
        if isa(line, LineNumberNode) # Don't eat line numbers
        elseif isa(line, Symbol)
            outputs = [line]
        elseif line.head == :(=)
            outputs = parse_assign!(ops, info, line.args...)
        elseif line.head == :call || line.head == :(.)
            outputs = [parse_arg!(ops, info, line)]
        elseif line.head == :return && isa(line.args[1], Symbol)
            outputs = [line.args[1]]
        elseif line.head == :tuple || line.head == :return && line.args[1].head != :tuple
            outputs = [parse_arg!(ops, info, arg) for arg in line.args]
        elseif line.head == :return && line.args[1].head == :tuple
            outputs = [parse_arg!(ops, info, arg) for arg in line.args[1].args]
        elseif line.head == :line
            info = line
        else error("In function $expr do not know how to handle $(line.head) on $line")
        end
    end
    Op(name, inputs, outputs, ops, info, mapping)
end

function parse_assign!(ops, info, vals, expr::Symbol)
    @assert vals.head == :tuple "In assignment $vals = $expr do not know how to handle $(vals.head)"
    outputs = [vals.args...]
    push!(ops, Op(:fanout, [expr], outputs, [], info))
    outputs
end

function parse_assign!(ops, info, vals, expr::Expr)
    func, inputs = parse_expr!(ops, info, expr)
    outputs = outs(vals)
    push!(ops, Op(func, inputs, outputs, [], info))
    outputs
end

outs(vals::Symbol) = [vals]
outs(vals::SlotNumber) = [Symbol(string(vals))]
outs(vals::Expr) = [vals.args...]

function parse_expr!(ops, info, expr::Expr)
    if expr.head == :tuple
        args = [parse_arg!(ops, info, arg) for arg in expr.args]
        :tuple, args
    elseif expr.head == :call
        if isa(expr.args[1], GlobalRef)
            expr.args[1] = expr.args[1].name
        end
        args = [parse_arg!(ops, info, arg) for arg in expr.args[2:end]]
        while length(args) > 2 && (expr.args[1] == :(+) || expr.args[1] == :(*))
            a = shift!(args)
            arg = Symbol("tmp$(length(ops)+1)")
            push!(ops, Op(opname(expr.args[1]), [a, args[1]], [arg], [], info))
            args[1] = arg
        end
        opname(expr.args[1]), args
    elseif expr.head == :(.)
        @assert expr.args[2].head == :tuple
        "dot_$(expr.args[1])", [parse_arg!(ops, info, arg) for arg in expr.args[2].args]
    elseif expr.head == :ref
        args = [parse_arg!(ops, info, arg) for arg in expr.args]
        :ref, args
    elseif expr.head == :(:)
        args = [parse_arg!(ops, info, arg) for arg in expr.args]
        :colon, args
    else error("In expr $expr do not know how to handle $(expr.head)")
    end
end

opname(name) = get(opnames, name, name)
const opnames = Dict(:(.*) => :dot_times, :(*) => :times, :(.+) => :dot_plus, :(+) => :plus,
                     :(./) => :dot_divide, :(/) => :divide, :(.-) => :dot_minus, :(-) => :minus,
                     :(.^) => :dot_power, :(^) => :power, :getindex => :ref)

function parse_arg!(ops, info, arg::Expr)
    func, inputs = parse_expr!(ops, info, arg)
    arg = Symbol("tmp$(length(ops)+1)")
    push!(ops, Op(func, inputs, [arg], [], info))
    arg
end

parse_arg!(ops, info, arg::Symbol) = arg
parse_arg!(ops, info, arg::Number) = arg
parse_arg!(ops, info, arg::SlotNumber) = Symbol(string(arg))
