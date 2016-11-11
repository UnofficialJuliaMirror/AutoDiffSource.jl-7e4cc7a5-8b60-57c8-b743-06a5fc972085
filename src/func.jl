δabs(x) = (abs(x), z->z*sign(x))

δdivide(x::AbstractArray, y::AbstractFloat) = (t = x/y; (t, z->(z/y, -sum(z.*t./y))))
δdivide(x::AbstractFloat, y::AbstractFloat) = (t = x/y; (t, z->(z/y, -z*t/y)))
δdivide_1(x, y) = (t = x/y; (t, z->(-z*t/y)))
δdivide_2(x, y) = (x/y, z->(z/y))

δdot(x, y) = (dot(x, y), z->(z.*y, z.*x))

δdot_abs(x) = (abs.(x), z->z.*sign.(x))

δdot_divide(x::AbstractArray, y::AbstractFloat) = (t = x./y; (t, z->(z./y, -sum(z.*t)/y)))
δdot_divide(x::AbstractFloat, y::AbstractArray) = (t = x./y; (t, z->(sum(z./y), -z.*t./y)))
δdot_divide(x::AbstractMatrix, y::AbstractVector) = (t = x./y; (t, z->(z./y, -sum(z.*t./y, 2))))
δdot_divide(x::AbstractVector, y::AbstractMatrix) = (t = x./y; (t, z->(sum(z./y, 2), -z.*t./y)))
δdot_divide_1(x, y) = (t = x./y; (t, z->(-z.*t./y)))
δdot_divide_2(x, y) = (x./y, z->(z./y))
δdot_divide{T}(x::T, y::T) = (t = x./y; (t, z->(z./y, -z.*t./y)))

δdot_exp(x) = (t = exp.(x); (t, z->z.*t))
δdot_log(x) = (log.(x), z->z./x)

δdot_minus(x::AbstractArray, y::AbstractFloat) = (x.-y, z->(z, -sum(z)))
δdot_minus(x::AbstractFloat, y::AbstractArray) = (x.-y, z->(sum(z), -z))
δdot_minus(x::AbstractMatrix, y::AbstractVector) = (x.-y, z->(z, -sum(z, 2)))
δdot_minus(x::AbstractVector, y::AbstractMatrix) = (x.-y, z->(sum(z, 2), -z))
δdot_minus_1(x, y) = (x.-y, z->-z)
δdot_minus_2(x, y) = (x.-y, z->z)
δdot_minus{T}(x::T, y::T) = (x.-y, z->(z, -z))

δdot_plus(x::AbstractArray, y::AbstractFloat) = (x.+y, z->(z, sum(z)))
δdot_plus(x::AbstractFloat, y::AbstractArray) = (x.+y, z->(sum(z), z))
δdot_plus(x::AbstractMatrix, y::AbstractVector) = (x.+y, z->(z, sum(z, 2)))
δdot_plus(x::AbstractVector, y::AbstractMatrix) = (x.+y, z->(sum(z, 2), z))
δdot_plus_1(x, y) = (x.+y, z->z)
δdot_plus_2(x, y) = (x.+y, z->z)
δdot_plus{T}(x::T, y::T) = (x.+y, z->(z, z))

δdot_power(x::AbstractArray, y::AbstractFloat) = (t = x.^y; (t, z->(z.*y.*t./x, sum(z.*t.*log.(x)))))
δdot_power(x::AbstractFloat, y::AbstractArray) = (t = x.^y; (t, z->(sum(z.*y.*t)/x, z.*t.*log.(x))))
δdot_power(x::AbstractMatrix, y::AbstractVector) = (t = x.^y; (t, z->(z.*y.*t./x, sum(z.*t.*log.(x), 2))))
δdot_power(x::AbstractVector, y::AbstractMatrix) = (t = x.^y; (t, z->(sum(z.*y.*t./x, 2), z.*t.*log.(x))))
δdot_power_1(x, y) = (t = x.^y; (t, z->z.*t.*log(x)))
δdot_power_2(x, y) = (t = x.^y; (t, z->z.*y.*t./x))
δdot_power{T}(x::T, y::T) = (t = x.^y; (t, z->(z.*y.*t./x, z.*t.*log.(x))))

δdot_sign(x::AbstractArray) = (sign.(x), y->zeros(y))

δdot_sqrt(x) = (t = sqrt.(x); (t, z->0.5*z./t))

δdot_times(x::AbstractArray, y::AbstractFloat) = (x.*y, z->(z.*y, sum(z.*x)))
δdot_times(x::AbstractFloat, y::AbstractArray) = (x.*y, z->(sum(z.*y), z.*x))
δdot_times(x::AbstractMatrix, y::AbstractVector) = (x.*y, z->(z.*y, sum(z.*x, 2)))
δdot_times(x::AbstractVector, y::AbstractMatrix) = (x.*y, z->(sum(z.*y, 2), z.*x))
δdot_times_1(x, y) = (x.*y, z->(z.*x))
δdot_times_2(x, y) = (x.*y, z->(z.*y))
δdot_times{T}(x::T, y::T) = (x.*y, z->(z.*y, z.*x))

δexp(x) = (t = exp(x); (t, z->z*t))
δfanout(x) = (x..., (z...) -> z)
δlog(x) = (log(x), z->z/x)

δminus(x) = (-x, z->-z)
δminus(x::AbstractArray, y::AbstractFloat) = (x-y, z->(z, -sum(z)))
δminus(x::AbstractFloat, y::AbstractArray) = (x-y, z->(sum(z), -z))
δminus_1(x, y) = (x-y, z->-z)
δminus_2(x, y) = (x-y, z->z)
δminus{T}(x::T, y::T) = (x-y, z->(z, -z))

δplus(x::AbstractArray, y::AbstractFloat) = (x+y, z->(z, sum(z)))
δplus(x::AbstractFloat, y::AbstractArray) = (x+y, z->(sum(z), z))
δplus_1(x, y) = (x+y, z->z)
δplus_2(x, y) = (x+y, z->z)
δplus{T}(x::T, y::T) = (x+y, z->(z, z))

δpower(x::AbstractFloat, y::AbstractFloat) = (t = x^y; (t, z->(z*y*t/x, z*t*log(x))))
δpower_1(x, y) = (t = x^y; (t, z->z*t*log(x)))
δpower_2(x, y) = (t = x^y; (t, z->z*y*t/x))

δsqrt(x) = (t = sqrt(x); (t, z->0.5*z/t))

δsign(x::AbstractFloat) = (sign(x), y->0.)

δsum(x) = (t = size(x); (sum(x), z->fill(z, t)))
δsum(x::AbstractFloat) = (x, z->z)

δtimes(x::AbstractArray, y::AbstractArray) = (x*y, z->(z*y', x'*z))
δtimes(x::AbstractArray, y::AbstractFloat) = (x*y, z->(z.*y, sum(z.*x)))
δtimes(x::AbstractFloat, y::AbstractArray) = (x*y, z->(sum(z.*y), z.*x))
δtimes(x::AbstractFloat, y::AbstractFloat) = (x*y, z->(z*y, z*x))
δtimes_1(x, y) = (x*y, z->(z*x))
δtimes_2(x, y) = (x*y, z->(z*y))

δlog1p(x) = (log1p(x), z->z/(1 + x))
δdot_log1p(x) = (log1p.(x), z->z./(1 + x))

δexpm1(x) = (t = expm1(x); (t, z->z*(1 + t)))
δdot_expm1(x) = (t = expm1.(x); (t, z->z.*(1 + t)))

δsin(x) = (sin(x), z->z*cos(x))
δdot_sin(x) = (sin.(x), z->z.*cos.(x))

δcos(x) = (cos(x), z->-z*sin(x))
δdot_cos(x) = (cos.(x), z->-z.*sin.(x))

δtan(x) = (t = tan(x); (t, z->z*(1+t*t)))
δdot_tan(x) = (t = tan.(x); (t, z->z.*(1+t.*t)))

δsinh(x) = (sinh(x), z->z*cosh(x))
δdot_sinh(x) = (sinh.(x), z->z.*cosh.(x))

δcosh(x) = (cosh(x), z->z*sinh(x))
δdot_cosh(x) = (cosh.(x), z->z.*sinh.(x))

δtanh(x) = (t = tanh(x); (t, z->z*(1-t*t)))
δdot_tanh(x) = (t = tanh.(x); (t, z->z.*(1-t.*t)))

δasin(x) = (asin(x), z->z/sqrt(1-x*x))
δdot_asin(x) = (asin.(x), z->z./sqrt.(1-x.*x))

δacos(x) = (acos(x), z->-z/sqrt(1-x*x))
δdot_acos(x) = (acos.(x), z->-z./sqrt.(1-x.*x))

δatan(x) = (atan(x), z->z/(1+x*x))
δdot_atan(x) = (atan.(x), z->z./(1+x.*x))

δround(x::AbstractFloat) = (round(x), y->0.)
δdot_round(x::AbstractArray) = (round.(x), y->zeros(y))

δceil(x::AbstractFloat) = (ceil(x), y->0.)
δdot_ceil(x::AbstractArray) = (ceil.(x), y->zeros(y))

δfloor(x::AbstractFloat) = (floor(x), y->0.)
δdot_floor(x::AbstractArray) = (floor.(x), y->zeros(y))

δtrunc(x::AbstractFloat) = (trunc(x), y->0.)
δdot_trunc(x::AbstractArray) = (trunc.(x), y->zeros(y))

δmod2pi(x::AbstractFloat) = (mod2pi(x), y->y)
δdot_mod2pi(x::AbstractArray) = (mod2pi.(x), y->y)

δmaximum(x) = (t=maximum(x); (t, y->(t.==x).*y))
δminimum(x) = (t=minimum(x); (t, y->(t.==x).*y))

δtranspose(x) = (x', y->y')

δerf(x) = (erf(x), y->y*2/sqrt(π)*exp(-x*x))
δdot_erf(x) = (erf.(x), y->y.*2/sqrt(π).*exp.(-x.*x))

δerfc(x) = (erfc(x), y->-y*2/sqrt(π)*exp(-x*x))
δdot_erfc(x) = (erfc.(x), y->-y.*2/sqrt(π).*exp.(-x.*x))

δgamma(x) = (t=gamma(x); (t, y->y*polygamma(0,x)*t))
δdot_gamma(x) = (t=gamma.(x); (t, y->y.*polygamma.(0,x).*t))

δlgamma(x) = (lgamma(x), y->y*polygamma(0,x))
δdot_lgamma(x) = (lgamma.(x), y->y.*polygamma.(0,x))
