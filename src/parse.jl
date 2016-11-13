type Op
    name::Symbol
    inputs::Vector
    outputs::Vector
    body::Vector
    info::Expr

    function Op(name, inputs, outputs, body, info)
        if !isempty(body)
            constants = Dict{Symbol, Symbol}()
            for op in body
                map!(x -> get(constants, x, x), op.inputs)
                if isdefined(Symbol("δ$(op.name)_const")) || all(isconst, op.inputs)
                    [constants[o] = Symbol("$(o)_const") for o in filter(isvar, op.outputs)]
                end
                map!(x -> get(constants, x, x), op.outputs)
                op.name = name_const(op.name, op.inputs, op.outputs)
            end
            map!(x -> get(constants, x, x), outputs)
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

function parse_function(expr)
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
        if line.head == :(=)
            outputs = parse_assign!(ops, info, line.args...)
        elseif line.head == :call || line.head == :(.)
            outputs = [parse_arg!(ops, info, line)]
        elseif line.head == :tuple || line.head == :return && line.args[1].head != :tuple
            outputs = [parse_arg!(ops, info, arg) for arg in line.args]
        elseif line.head == :return && line.args[1].head == :tuple
            outputs = [parse_arg!(ops, info, arg) for arg in line.args[1].args]
        elseif line.head == :line
            info = line
        else error("In function $expr do not know how to handle $(line.head) on $line")
        end
    end
    Op(name, inputs, outputs, ops, info)
end

function parse_assign!(ops, info, vals, expr::Symbol)
    @assert vals.head == :tuple "In assignment $vals = $expr do not know how to handle $(vals.head)"
    outputs = [vals.args...]
    push!(ops, Op(:fanout, [expr], outputs, [], info))
    outputs
end

function parse_assign!(ops, info, vals, expr::Expr)
    func, inputs = parse_expr!(ops, info, expr)
    outputs = typeof(vals) == Symbol ? [vals] : [vals.args...]
    push!(ops, Op(func, inputs, outputs, [], info))
    outputs
end

function parse_expr!(ops, info, expr::Expr)
    if expr.head == :tuple
        args = [parse_arg!(ops, info, arg) for arg in expr.args]
        :tuple, args
    elseif expr.head == :call
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
                     :(.^) => :dot_power, :(^) => :power)

function parse_arg!(ops, info, arg::Expr)
    func, inputs = parse_expr!(ops, info, arg)
    arg = Symbol("tmp$(length(ops)+1)")
    push!(ops, Op(func, inputs, [arg], [], info))
    arg
end

parse_arg!(ops, info, arg::Symbol) = arg
parse_arg!(ops, info, arg::Number) = arg
