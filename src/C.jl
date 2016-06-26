immutable C{T<:Simple} <: Towering r::T; i::T end

real{T<:Simple}(z::C{T}) = isnan(z.i) ? z.i : z.r
imag{T<:Simple}(z::C{T}) = isnan(z.r) ? z.r : z.i

zero{T}(::Type{C{T}}) = C(zero(T), zero(T))
one{T}(::Type{C{T}}) = C(one(T), zero(T))

complex{T}(r::T) = C(r, zero(T))
complex{T}(r::T, i::T) = C(r, i)

isnan{T<:Simple}(z::C{T}) = isnan(real(z)) || isnan(imag(z))

=={T<:Simple}(z::C{T}, w::C{T}) = ((isnan(z) && isnan(w)) ||
                                   (real(z) == real(w) &&
                                    imag(z) == imag(w)))

# a total order - should have a separate partial <
function isless{T<:Simple}(z::C{T}, w::C{T})
    isnan(w) < isnan(z) ||
    (real(z) < real(w)) ||
    (real(z) == real(w) && imag(z) < imag(w))
end

# not bothering with a best(z) - unlike in Q, it would only normalize
# NaN and nothing more

function +{T<:Simple}(z::C{T}, w::C{T})
    a, b, c, d = real(z), imag(z), real(w), imag(w)
    C(a + c, b + d)
end

function *{T<:Simple}(z::C{T}, w::C{T})
    a, b, c, d = real(z), imag(z), real(w), imag(w)
    C(a*c - b*d, a*d + b*c)
end

function -{T<:Simple}(z::C{T})
    a, b = real(z), imag(z)
    C(-a, -b)
end

function inv{T<:Simple}(z::C{T})
    a, b = real(z), imag(z)
    C(a/(a^2 + b^2), b/(a^2 + b^2))
end
