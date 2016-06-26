immutable Halves<:Material o::Rational{BigInt} end
immutable Inverses<:Material o::Rational{BigInt} end
immutable Naturals<:Material o::BigInt end
immutable Positives<:Material o::BigInt end
immutable Tallies<:Material o::ASCIIString end

# isnan(n::Material) = false # because C{T} - oh, it needed -, too

zero(::Type{Halves}) = Halves(1)
next(n::Halves) = Halves(n.o/2)

zero(::Type{Inverses}) = Inverses(1)
next(n::Inverses) = Inverses(1/(1/n.o + 1))

zero(::Type{Naturals}) = Naturals(0)
next(n::Naturals) = Naturals(n.o + 1)

zero(::Type{Positives}) = Positives(1)
next(n::Positives) = Positives(n.o + 1)

zero(::Type{Tallies}) = Tallies("")
next(n::Tallies) = Tallies(n.o * "/")

=={T<:Material}(m::T, n::T) = m.o == n.o

# Rest is on Material zero and next.

# All higher level Towering types have one instead of next.

one{T<:Material}(::Type{T}) = next(zero(T))

# Integer division depends on the order predicate that in turn depends
# on the material order predicate. Material division is not essential.

function isless{T<:Material}(m::T, n::T)
    step(w::T, u::T) = w == m || (u != n && step(next(w), next(u)))
    m != n && step(zero(T), zero(T))
end

# Addition and multiplication on each Material type are defined
# entirely in terms of the zero and next of that type. Other Towering
# types have their own definitions. Exponentiation for any Towering
# base and Material exponent is defined as repeated multiplication.

function +{T<:Material}(m::T, n::T)
    step(s::T) = next(s)
    step(s::T, k::T, n::T) = (k == n) ? s : step(step(s), next(k), n)
    step(m, zero(T), n)
end

function *{T<:Material}(m::T, n::T)
    step(p::T) = p + m
    step(p::T, k::T, n::T) = (k == n) ? p : step(step(p), next(k), n)
    step(zero(T), zero(T), n)
end

function ^{T<:Towering,U<:Material}(m::T, n::U)
    step(p::T) = p * m
    step(p::T, k::U, n::U) = (k == n) ? p : step(step(p), next(k), n)
    step(one(T), zero(U), n)
end
