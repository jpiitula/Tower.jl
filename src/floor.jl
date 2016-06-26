# to decide whether to keep this at all

# ---- comments here need editing - this is a side show and not needed
#      for integer division which is defined in terms of integers ----

# Euclidean division is defined in order to build best representations
# of rational numbers: integer division will be reduced to sign
# analysis and natural division, the lowest-terms rational will then
# be found by the "extended Euclidean algorithm". A plan, anyway.
# (*Is* this Euclidean? Flooring? *This* is both, and will not be
# important for rationals - use "extended Euclidean algorithm" in
# *integers*, where there are also negative numbers - so consider
# whether this will be here at all and then maybe both as divrem and
# as fldmod.)

function divrem{T<:Material}(m::T, n::T)
    function step(q::T, r::T, k::T)
        if r == n step(next(q), zero(T), k)
        elseif k == m; (q,r)
        else step(q, next(r), next(k)) end
    end
    if n == zero(T); (n,m) else step(zero(T), zero(T), zero(T)) end
end

div{T<:Material}(m::T, n::T) = ((q, r) = divrem(m, n); q)
rem{T<:Material}(m::T, n::T) = ((q, r) = divrem(m, n); r)

fldmod{T<:Material}(m::T, n::T) = divrem(m, n)
fld{T<:Material}(m::T, n::T) = div(m, n)
mod{T<:Material}(m::T, n::T) = rem(m, n)

# Need lowest terms for *Z*, extended Euclidean algorithm, gcd; should
# there still be also lowest terms or gcd for N? what about testing
# greater or less? But use natural div to implement integer division
# and remainder. (Division by zero is accidental on remainder, which
# is somewhat motivated; see if it works well with gcd and lowest
# terms.) - Implement positive rationals directly on naturals?
