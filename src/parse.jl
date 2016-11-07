type Op
    name::Symbol
    inputs::Vector
    outputs::Vector
    body::Vector
    info::Expr
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
            outputs = parse_kw!(ops, info, line.args...)
        elseif line.head == :call || line.head == :(.)
            outputs = [parse_arg!(ops, info, line)]
        elseif line.head == :tuple
            outputs = [parse_arg!(ops, info, arg) for arg in line.args]
        elseif line.head == :line
            info = line
        else
            error("Do not know how to handle $(line.head) on $line")
        end
    end
    Op(name, inputs, outputs, ops, info)
end

function parse_kw!(ops, info, vals, expr::Symbol)
    @assert vals.head == :tuple "Do not know how to handle $(vals.head) on $vals"
    func = "fanout"
    if length(vals.args) <= 12
        func *= string(length(vals.args))
    end
    outputs = [vals.args...]
    push!(ops, Op(func, [expr], outputs, [], info))
    outputs
end

function parse_kw!(ops, info, vals, expr::Expr)
    func, inputs = parse_expr!(ops, info, expr)
    outputs = typeof(vals) == Symbol ? [vals] : [vals.args...]
    push!(ops, Op(func, inputs, outputs, [], info))
    outputs
end

function parse_expr!(ops, info, expr::Expr)
    @assert expr.head == :call || expr.head == :(.) "Do not know how to handle $(expr.head) on $expr"
    if expr.head == :call
        args = [parse_arg!(ops, info, arg) for arg in expr.args[2:end]]
        opname(expr.args[1]), args
    elseif expr.args[2].head == :tuple
        "dot$(expr.args[1])", [parse_arg!(ops, info, arg) for arg in expr.args[2].args]
    else
        error("Do not know how to handle $(expr.head) on $expr")
    end
end

opname(name) = get(opnames, name, name)
const opnames = Dict(:(.*) => :dottimes, :(*) => :times, :(.+) => :dotplus, :(+) => :plus,
                     :(./) => :dotdivide, :(/) => :divide, :(.-) => :dotminus, :(-) => :minus,
                     :(.^) => :dotpower, :(^) => :power)

function parse_arg!(ops, info, arg::Expr)
    func, inputs = parse_expr!(ops, info, arg)
    arg = Symbol("tmp$(length(ops)+1)")
    push!(ops, Op(func, inputs, [arg], [], info))
    arg
end

parse_arg!(ops, info, arg::Symbol) = arg
parse_arg!(ops, info, arg::Number) = arg
