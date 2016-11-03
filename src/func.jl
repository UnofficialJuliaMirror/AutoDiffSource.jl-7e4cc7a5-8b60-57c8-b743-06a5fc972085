δplus(x::AbstractFloat, y::AbstractFloat) = (x+y, z->(z, z))

δtimes(x::AbstractFloat, y::AbstractFloat) = (x*y, z->(y*z, x*z))
