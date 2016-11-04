δplus(x::AbstractFloat, y::AbstractFloat) = (x+y, z->(z, z))
δminus(x::AbstractFloat, y::AbstractFloat) = (x-y, z->(z, -z))
δtimes(x::AbstractFloat, y::AbstractFloat) = (x*y, z->(z*y, z*x))
δdivide(x::AbstractFloat, y::AbstractFloat) = (t = x/y; (t, z->(z/y, -z*t/y)))
δpower(x::AbstractFloat, y::AbstractFloat) = (t = x^y; (t, z->(z*y*t/x, z*t*log(x))))

δabs(x) = (abs(x), z->z*sign(x))
δsum(x::AbstractFloat) = (x, z->z)
δsum(x::AbstractArray) = (t = size(x); (sum(x), z->fill(z, t)))
δsqrt(x) = (t = sqrt(x); (t, z->0.5*z/t))
δexp(x) = (t = exp(x); (t, z->z*t))
δlog(x) = (log(x), z->z/x)

δdotabs(x) = (abs.(x), z->z.*sign.(x))

# δpower
# δdottimes, δdotdivide, δdotabs, δdotsqrt, δdotexp, δdotlog, δdotpower
