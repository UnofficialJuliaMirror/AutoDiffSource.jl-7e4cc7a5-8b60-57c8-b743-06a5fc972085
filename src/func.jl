δabs(x) = (abs(x), z->z*sign(x))

δdivide(x::AbstractArray, y::AbstractFloat) = (t = x/y; (t, z->(z/y, -sum(z.*t./y))))
δdivide(x::AbstractFloat, y::AbstractFloat) = (t = x/y; (t, z->(z/y, -z*t/y)))
δdivide_1(x, y) = (t = x/y; (t, z->(-z*t/y)))
δdivide_2(x, y) = (x/y, z->(z/y))

δdotabs(x) = (abs.(x), z->z.*sign.(x))

δdotdivide(x::AbstractArray, y::AbstractFloat) = (t = x./y; (t, z->(z./y, -sum(z.*t)/y)))
δdotdivide(x::AbstractFloat, y::AbstractArray) = (t = x./y; (t, z->(sum(z./y), -z.*t./y)))
δdotdivide(x::AbstractMatrix, y::AbstractVector) = (t = x./y; (t, z->(z./y, -sum(z.*t./y, 2))))
δdotdivide(x::AbstractVector, y::AbstractMatrix) = (t = x./y; (t, z->(sum(z./y, 2), -z.*t./y)))
δdotdivide_1(x, y) = (t = x./y; (t, z->(-z.*t./y)))
δdotdivide_2(x, y) = (x./y, z->(z./y))
δdotdivide{T}(x::T, y::T) = (t = x./y; (t, z->(z./y, -z.*t./y)))

δdotexp(x) = (t = exp.(x); (t, z->z.*t))
δdotlog(x) = (log.(x), z->z./x)

δdotminus(x::AbstractArray, y::AbstractFloat) = (x.-y, z->(z, -sum(z)))
δdotminus(x::AbstractFloat, y::AbstractArray) = (x.-y, z->(sum(z), -z))
δdotminus(x::AbstractMatrix, y::AbstractVector) = (x.-y, z->(z, -sum(z, 2)))
δdotminus(x::AbstractVector, y::AbstractMatrix) = (x.-y, z->(sum(z, 2), -z))
δdotminus_1(x, y) = (x.-y, z->-z)
δdotminus_2(x, y) = (x.-y, z->z)
δdotminus{T}(x::T, y::T) = (x.-y, z->(z, -z))

δdotplus(x::AbstractArray, y::AbstractFloat) = (x.+y, z->(z, sum(z)))
δdotplus(x::AbstractFloat, y::AbstractArray) = (x.+y, z->(sum(z), z))
δdotplus(x::AbstractMatrix, y::AbstractVector) = (x.+y, z->(z, sum(z, 2)))
δdotplus(x::AbstractVector, y::AbstractMatrix) = (x.+y, z->(sum(z, 2), z))
δdotplus_1(x, y) = (x.+y, z->z)
δdotplus_2(x, y) = (x.+y, z->z)
δdotplus{T}(x::T, y::T) = (x.+y, z->(z, z))

δdotpower(x::AbstractArray, y::AbstractFloat) = (t = x.^y; (t, z->(z.*y.*t./x, sum(z.*t.*log.(x)))))
δdotpower(x::AbstractFloat, y::AbstractArray) = (t = x.^y; (t, z->(sum(z.*y.*t)/x, z.*t.*log.(x))))
δdotpower(x::AbstractMatrix, y::AbstractVector) = (t = x.^y; (t, z->(z.*y.*t./x, sum(z.*t.*log.(x), 2))))
δdotpower(x::AbstractVector, y::AbstractMatrix) = (t = x.^y; (t, z->(sum(z.*y.*t./x, 2), z.*t.*log.(x))))
δdotpower_1(x, y) = (t = x.^y; (t, z->z.*t.*log(x)))
δdotpower_2(x, y) = (t = x.^y; (t, z->z.*y.*t./x))
δdotpower{T}(x::T, y::T) = (t = x.^y; (t, z->(z.*y.*t./x, z.*t.*log.(x))))

δdotsign(x::AbstractArray) = (sign.(x), y->zeros(y))

δdotsqrt(x) = (t = sqrt.(x); (t, z->0.5*z./t))

δdottimes(x::AbstractArray, y::AbstractFloat) = (x.*y, z->(z.*y, sum(z.*x)))
δdottimes(x::AbstractFloat, y::AbstractArray) = (x.*y, z->(sum(z.*y), z.*x))
δdottimes(x::AbstractMatrix, y::AbstractVector) = (x.*y, z->(z.*y, sum(z.*x, 2)))
δdottimes(x::AbstractVector, y::AbstractMatrix) = (x.*y, z->(sum(z.*y, 2), z.*x))
δdottimes_1(x, y) = (x.*y, z->(z.*x))
δdottimes_2(x, y) = (x.*y, z->(z.*y))
δdottimes{T}(x::T, y::T) = (x.*y, z->(z.*y, z.*x))

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
