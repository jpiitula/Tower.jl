immutable Q{T<:Material} <: Simple n::Z{T}; d::Z{T} end

zero{T<:Material}(::Type{Q{T}}) = Q(zero(Z{T}), one(Z{T}))
one{T<:Material}(::Type{Q{T}}) = Q(one(Z{T}), one(Z{T}))

# making n/0 a NaN for all n, for all operations - and NaN
# less than any other value of the same type, equal to NaN,
# so unlike IEEE float

isnan{T<:Material}(r::Q{T}) = r.d == zero(Z{T})

function =={T<:Material}(p::Q{T}, q::Q{T})
    (isnan(p) && isnan(q)) || p.n * q.d == q.n * p.d
end

function isless{T<:Material}(p::Q{T}, q::Q{T})
    isnan(q) < isnan(p) || p.n * q.d < q.n * p.d
end

"""
    A "best" pair (m, n) of integers to represent a rational
    is one where m and n are in lowest terms and either n is
    positive or both are zero.
"""
function best{T<:Material}(p::Q{T})
    O = zero(Z{T})
    if isnan(p)
        Q(O, O)
    else
        n, d = lowest(p.n, p.d)
        Q(n, d)
    end
end

+{T<:Material}(p::Q{T}, r::Q{T}) = best(Q(p.n * r.d + r.n * p.d, p.d * r.d))
*{T<:Material}(p::Q{T}, r::Q{T}) = best(Q(p.n * r.n, p.d * r.d))

# the following should work correctly even if r is not the canonical
# best, but then it should also work best when r is best

-{T<:Material}(r::Q{T}) = Q(-r.n, r.d)

function inv{T<:Material}(r::Q{T})
    O = zero(Z{T})
    if isnan(r)
        Q(O, O)
    else
        Q(sign(r.n) * r.d, abs(r.n))
    end
end

# define division once for all Towering types that have multiplicative
# inverses (that would be rationals and complex rationals)

/{T<:Towering}(x::T, y::T) = x * inv(y)
