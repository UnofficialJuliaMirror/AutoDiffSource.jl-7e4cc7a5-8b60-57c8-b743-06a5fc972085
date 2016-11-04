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
            error("Do not know how to handle $line")
        end
    end
    Op(name, inputs, outputs, ops, info)
end

function parse_kw!(ops, info, vals, expr)
    func, inputs = parse_expr!(ops, info, expr)
    outputs = typeof(vals) == Symbol ? [vals] : [vals.args...]
    push!(ops, Op(func, inputs, outputs, [], info))
    outputs
end

function parse_expr!(ops, info, expr)
    @assert expr.head == :call || expr.head == :(.) "Do not know how to handle $expr"
    if expr.head == :call
        pretty(expr.args[1]), [parse_arg!(ops, info, arg) for arg in expr.args[2:end]]
    else
        @assert expr.args[2].head == :tuple "Do not know how to handle $expr"
        "dot$(expr.args[1])", [parse_arg!(ops, info, arg) for arg in expr.args[2].args]
    end
end

pretty(name) = get(opnames, name, name)

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
