δmulticast(f, x::AbstractFloat) = f(x)

function δmulticast(f, x::AbstractArray)
    iter = Base.CartesianRange(size(x))
    temp = next(iter, start(iter))
    I = temp[1]
    st = temp[2]
    val = f(x[I])
    v = similar(Array{typeof(val[1])}, size(x))
    ∇v = similar(Array{typeof(val[2])}, size(x))
    v[I] = val[1]
    ∇v[I] = val[2]
    while !done(iter, st)
        I, st = next(iter, st)
        v[I], ∇v[I] = f(x[I])
    end
    v, u -> ∇multicast(∇v, u)
end

function ∇multicast(∇v, x)
    iter = Base.CartesianRange(size(x))
    st = start(iter)
    I, st = next(iter, st)
    val = ∇v[I](x[I])
    v = similar(Array{typeof(val)}, size(x))
    v[I] = val
    while !done(iter, st)
        I, st = next(iter, st)
        v[I] = ∇v[I](x[I])
    end
    v
end

δmulticast(f, x1::AbstractFloat, x2::AbstractFloat) = f(x1, x2)
δmulticast_const1(f, x1::AbstractFloat, x2::AbstractFloat) = f(x1, x2)
δmulticast_const2(f, x1::AbstractFloat, x2::AbstractFloat) = f(x1, x2)

function δmulticast(f, x1::AbstractArray, x2::AbstractArray)
    iter = Base.CartesianRange(size(x1))
    temp = next(iter, start(iter))
    I = temp[1]
    st = temp[2]
    val = f(x1[I], x2[I])
    v = similar(Array{typeof(val[1])}, size(x1))
    ∇v = similar(Array{typeof(val[2])}, size(x1))
    v[I] = val[1]
    ∇v[I] = val[2]
    while !done(iter, st)
        I, st = next(iter, st)
        v[I], ∇v[I] = f(x1[I], x2[I])
    end
    v, u -> ∇multicast2(∇v, u)
end

function ∇multicast2(∇v, x)
    iter = Base.CartesianRange(size(x))
    st = start(iter)
    I, st = next(iter, st)
    val = ∇v[I](x[I])
    v1 = similar(Array{typeof(val[1])}, size(x))
    v2 = similar(Array{typeof(val[2])}, size(x))
    v1[I] = val[1]
    v2[I] = val[2]
    while !done(iter, st)
        I, st = next(iter, st)
        v1[I], v2[I] = ∇v[I](x[I])
    end
    v1, v2
end

function δmulticast_const1(f, x1::AbstractFloat, x2::AbstractArray)
    iter = Base.CartesianRange(size(x2))
    temp = next(iter, start(iter))
    I = temp[1]
    st = temp[2]
    val = f(x1, x2[I])
    v = similar(Array{typeof(val[1])}, size(x2))
    ∇v = similar(Array{typeof(val[2])}, size(x2))
    v[I] = val[1]
    ∇v[I] = val[2]
    while !done(iter, st)
        I, st = next(iter, st)
        v[I], ∇v[I] = f(x1, x2[I])
    end
    v, u -> ∇multicast(∇v, u)
end

function δmulticast_const2(f, x1::AbstractArray, x2::AbstractFloat)
    iter = Base.CartesianRange(size(x1))
    temp = next(iter, start(iter))
    I = temp[1]
    st = temp[2]
    val = f(x1[I], x2)
    v = similar(Array{typeof(val[1])}, size(x1))
    ∇v = similar(Array{typeof(val[2])}, size(x1))
    v[I] = val[1]
    ∇v[I] = val[2]
    while !done(iter, st)
        I, st = next(iter, st)
        v[I], ∇v[I] = f(x1[I], x2)
    end
    v, u -> ∇multicast(∇v, u)
end
