δplus(x::AbstractFloat, y::AbstractFloat) = (x+y, z->(z, z))


δminus(x::AbstractFloat, y::AbstractFloat) = (x-y, z->(z, -z))


δtimes(x::AbstractFloat, y::AbstractFloat) = (x*y, z->(z*y, z*x))


δdivide(x::AbstractFloat, y::AbstractFloat) = (t = x/y; (t, z->(z/y, -z*t/y)))
