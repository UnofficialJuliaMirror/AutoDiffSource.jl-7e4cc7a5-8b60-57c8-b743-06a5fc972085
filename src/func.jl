const δceil_const = true
const δcolon_const = true
const δfloor_const = true
const δlength_const = true
const δones_const = true
const δrand_const = true
const δrandn_const = true
const δref_const2 = true
const δround_const = true
const δsign_const = true
const δsize_const = true
const δsrand_const = true
const δtrunc_const = true
const δtuple = true
const δzeros_const = true

function fit(x, sz::Tuple{Int, Int})
    if size(x) == sz
        x
    elseif sz[1] == 1 && sz[2] != 1
        sum(x, 1)
    elseif sz[2] == 1 && sz[1] != 1
        sum(x, 2)
    else
        fill(sum(x), sz)
    end
end
function fit(x, sz::Tuple{Int})
    if size(x) == sz
        vec(x)
    elseif sz[1] == 1
        fill(sum(x), sz)
    else
        vec(sum(x, 2))
    end
end
fit(x, sz::Tuple{}) = sum(x)

safediv{T}(x::T, y) = y == 0 ? T(0) : x / y
δabs(x) = (abs(x), z->z*sign(x))
δacos(x) = (acos(x), z->-z/sqrt(1-x*x))
δasin(x) = (asin(x), z->z/sqrt(1-x*x))
δatan(x) = (atan(x), z->z/(1+x*x))
δcos(x) = (cos(x), z->-z*sin(x))
δcosh(x) = (cosh(x), z->z*sinh(x))
δdivide(x::AbstractArray, y::Real) = (t = x/y; (t, z->(z/y, -sum(z.*t)/y)))
δdivide(x::Real, y::Real) = (t = x/y; (t, z->(z/y, -z*t/y)))
δdivide_const1(x, y) = (t = x/y; (t, z->(-z*t/y)))
δdivide_const2(x, y) = (x/y, z->(z/y))
δdot(x, y) = (dot(x, y), z->(z.*y, z.*x))
δdot_divide(x::AbstractArray, y::Real) = (t = x./y; (t, z->(z./y, -sum(z.*t)/y)))
δdot_divide(x::Real, y::AbstractArray) = (t = x./y; (t, z->(sum(z./y), -z.*t./y)))
δdot_divide(x::AbstractMatrix, y::AbstractVector) = (t = x./y; (t, z->(z./y, vec(-sum(z.*t./y, 2)))))
δdot_divide(x::AbstractVector, y::AbstractMatrix) = (t = x./y; (t, z->(vec(sum(z./y, 2)), -z.*t./y)))
δdot_divide_const1(x, y) = (t = x./y; (t, z->(-z.*t./y)))
δdot_divide_const2(x, y) = (x./y, z->(z./y))
δdot_divide{T}(x::T, y::T) = (t = x./y; (t, z->(z./y, -z.*t./y)))
δdot_minus(x::AbstractArray, y::Real) = (x.-y, z->(z, -sum(z)))
δdot_minus(x::Real, y::AbstractArray) = (x.-y, z->(sum(z), -z))
δdot_minus(x::AbstractMatrix, y::AbstractVector) = (x.-y, z->(z, vec(-sum(z, 2))))
δdot_minus(x::AbstractVector, y::AbstractMatrix) = (x.-y, z->(vec(sum(z, 2)), -z))
δdot_minus_const1(x, y) = (x.-y, z->-z)
δdot_minus_const2(x, y) = (x.-y, z->z)
δdot_minus{T}(x::T, y::T) = (x.-y, z->(z, -z))
δdot_plus_const1(x, y) = (sy = size(y); (x.+y, z->fit(z, sy)))
δdot_plus_const2(x, y) = (sx = size(x); (x.+y, z->fit(z, sx)))
δdot_plus(x, y) = (sx = size(x); sy = size(y); (x.+y, z->(fit(z, sx), fit(z, sy))))
δdot_power(x::AbstractArray, y::Real) = (t = x.^y; (t, z->(safediv.(z.*y.*t, x), sum(z.*t.*log.(x)))))
δdot_power(x::Real, y::AbstractArray) = (t = x.^y; (t, z->(safediv(sum(z.*y.*t), x), z.*t.*log.(x))))
δdot_power(x::AbstractMatrix, y::AbstractVector) = (t = x.^y; (t, z->(safediv.(z.*y.*t, x), vec(sum(z.*t.*log.(x), 2)))))
δdot_power(x::AbstractVector, y::AbstractMatrix) = (t = x.^y; (t, z->(vec(sum(safediv.(z.*y.*t, x), 2)), z.*t.*log.(x))))
δdot_power_const1(x, y) = (t = x.^y; (t, z->z.*t.*log(x)))
δdot_power_const2(x, y) = (t = x.^y; (t, z-> y == 2 ? z.*2x : safediv.(z.*y.*t, x)))
δdot_power{T}(x::T, y::T) = (t = x.^y; (t, z->(safediv.(z.*y.*t, x), z.*t.*log.(x))))
δdot_times(x::AbstractArray, y::Real) = (x.*y, z->(z.*y, sum(z.*x)))
δdot_times(x::Real, y::AbstractArray) = (x.*y, z->(sum(z.*y), z.*x))
δdot_times(x::AbstractMatrix, y::AbstractVector) = (x.*y, z->(z.*y, vec(sum(z.*x, 2))))
δdot_times(x::AbstractVector, y::AbstractMatrix) = (x.*y, z->(vec(sum(z.*y, 2)), z.*x))
δdot_times_const1(x, y) = (x.*y, z->(z.*x))
δdot_times_const2(x, y) = (x.*y, z->(z.*y))
δdot_times{T}(x::T, y::T) = (x.*y, z->(z.*y, z.*x))
δerf(x) = (erf(x), y->y*2/sqrt(π)*exp(-x*x))
δerfc(x) = (erfc(x), y->-y*2/sqrt(π)*exp(-x*x))
δexp(x) = (t = exp(x); (t, z->z*t))
δexpm1(x) = (t = expm1(x); (t, z->z*(1 + t)))
δfanout(x) = (x..., (z...) -> z)
δgamma(x) = (t=gamma(x); (t, y->y*polygamma(0,x)*t))
δlgamma(x) = (lgamma(x), y->y*polygamma(0,x))
δlog(x) = (log(x), z->z/x)
δlog1p(x) = (log1p(x), z->z/(1 + x))
δmax(x, y) = (max(x, y), z->(z*(x>y),z*(x<y)))
δmax_const1(x, y) = (max(x, y), z->z*(x<y))
δmax_const2(x, y) = (max(x, y), z->z*(x>y))
δmaximum(x) = (t=maximum(x); (t, y->(t.==x).*y))
δmin(x, y) = (min(x, y), z->(z*(x<y),z*(x>y)))
δmin_const1(x, y) = (min(x, y), z->z*(x>y))
δmin_const2(x, y) = (min(x, y), z->z*(x<y))
δminimum(x) = (t=minimum(x); (t, y->(t.==x).*y))
δminus(x) = (-x, z->-z)
δminus(x::AbstractArray, y::Real) = (x-y, z->(z, -sum(z)))
δminus(x::Real, y::AbstractArray) = (x-y, z->(sum(z), -z))
δminus_const1(x, y) = (x-y, z->-z)
δminus_const2(x, y) = (x-y, z->z)
δminus_const1(x, y::Real) = (x-y, z->-sum(z))
δminus_const2(x::Real, y) = (x-y, z->sum(z))
δminus{T}(x::T, y::T) = (x-y, z->(z, -z))
δmod2pi(x::Real) = (mod2pi(x), y->y)
δplus(x::AbstractArray, y::Real) = (x+y, z->(z, sum(z)))
δplus(x::Real, y::AbstractArray) = (x+y, z->(sum(z), z))
δplus_const1(x, y) = (x+y, z->z)
δplus_const2(x, y) = (x+y, z->z)
δplus_const1(x, y::Real) = (x+y, z->sum(z))
δplus_const2(x::Real, y) = (x+y, z->sum(z))
δplus{T}(x::T, y::T) = (x+y, z->(z, z))
δpower(x::Real, y::Real) = (t = x^y; (t, z->(safediv(z*y*t, x), z*t*log(x))))
δpower_const1(x, y) = (t = x^y; (t, z->z*t*log(x)))
δpower_const2(x, y) = (t = x^y; (t, z->safediv(z*y*t, x)))
δsin(x) = (sin(x), z->z*cos(x))
δsinh(x) = (sinh(x), z->z*cosh(x))
δsqrt(x) = (t = sqrt(x); (t, z->0.5*z/t))
δsum(x::AbstractArray) = (t = size(x); (sum(x), z->fill(z, t)))
δsum(x::Real) = (x, z->z)
δtan(x) = (t = tan(x); (t, z->z*(1+t*t)))
δtanh(x) = (t = tanh(x); (t, z->z*(1-t*t)))
δtimes(x::AbstractVector, y::AbstractMatrix) = (x*y, z->(vec(z*y'), x'*z))
δtimes(x::AbstractMatrix, y::AbstractVector) = (x*y, z->(z*y', vec(x'*z)))
δtimes(x::AbstractMatrix, y::AbstractMatrix) = (x*y, z->(z*y', x'*z))
δtimes(x::AbstractArray, y::Real) = (x*y, z->(z.*y, sum(z.*x)))
δtimes(x::Real, y::AbstractArray) = (x*y, z->(sum(z.*y), z.*x))
δtimes(x::Real, y::Real) = (x*y, z->(z*y, z*x))
δtimes_const1(x, y) = (x*y, z->(x'*z))
δtimes_const1(x, y::Real) = (x*y, z->sum(x.*z))
δtimes_const2(x, y) = (x*y, z->(z*y'))
δtimes_const2(x::Real, y) = (x*y, z->sum(z.*y))
δtranspose(x::AbstractVector) = (x', y->vec(y'))
δtranspose(x) = (x', y->y')
δzeros(x::AbstractArray) = zeros(x)
δzeros{T}(x::T)::T = 0.
δmean(x::Real) = (x, z->z)
δmean(x::AbstractArray) = (t = size(x); (mean(x), z->fill(z/prod(t), t)))
