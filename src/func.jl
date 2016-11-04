δplus(x::AbstractFloat, y::AbstractFloat) = (x+y, z->(z, z))
δminus(x::AbstractFloat, y::AbstractFloat) = (x-y, z->(z, -z))
δtimes(x::AbstractFloat, y::AbstractFloat) = (x*y, z->(z*y, z*x))
δdivide(x::AbstractFloat, y::AbstractFloat) = (t = x/y; (t, z->(z/y, -z*t/y)))

δabs(x) = (abs(x), z->z*sign(x))
δsum(x::AbstractFloat) = (x, z->z)
δsum(x::AbstractArray) = (t = size(x); (sum(x), z->fill(z, t)))

δdotabs(x) = (abs.(x), z->z.*sign.(x))
