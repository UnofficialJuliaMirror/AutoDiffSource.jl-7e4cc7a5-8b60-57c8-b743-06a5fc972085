function δ(f)
    fs = methods(f)
    length(fs) >  0 || error("function '$f' not found")
    length(fs) <  2 || error("function '$f' has too many signatures")
    fdef  = fs.ms[1]
    fn = VERSION >= v"0.6.0-" ? Base.uncompressed_ast(fdef, fdef.source).code : Base.uncompressed_ast(fdef.lambda_template)
    fcode = fn[2:end]
    fargs = [Symbol("_$i") for i in 2:fdef.nargs]
    fname = Symbol(string(f))
    func = :(function $fname($(fargs...)); end)
    body = func.args[2].args
    empty!(body)
    foreach(arg -> push!(body, arg), fcode)
    op = parse_function(func)
    delta(op)
end
