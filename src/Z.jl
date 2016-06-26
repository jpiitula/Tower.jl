immutable Z{T<:Material} <: Simple p::T; n::T end

zero{T<:Material}(::Type{Z{T}}) = Z(zero(T), zero(T))
one{T<:Material}(::Type{Z{T}}) = Z(next(zero(T)), zero(T))

isnan(m::Z) = false

=={T<:Material}(m::Z{T}, n::Z{T}) = m.p + n.n == m.n + n.p

isless{T<:Material}(m::Z{T}, n::Z{T}) = m.p + n.n < n.p + m.n

"""
    A "best" pair (p, n) of Material numbers to represent an integer
    is one where at least one of p and n is the zero of that type.
"""
function best{T<:Material}(m::Z{T})
    function step(u::T, w::T, k::T)
        if k == u
            w
        else
            step(u, next(w), next(k))
        end
    end
    function walk(m::T, n::T, k::T)
        if k == m
            Z(zero(T), step(n, zero(T), k))
        elseif k == n
            Z(step(m, zero(T), k), zero(T))
        else
            walk(m, n, next(k))
        end
    end
    walk(m.p, m.n, zero(T))
end

+{T<:Material}(m::Z{T}, n::Z{T}) = best(Z(m.p + n.p, m.n + n.n))
*{T<:Material}(m::Z{T}, n::Z{T}) = best(Z(m.p * n.p + m.n * n.n,
                                          m.p * n.n + m.n * n.p))

-{T<:Material}(m::Z{T}) = Z(m.n, m.p)

# Subtraction is defined once for all Towering types that have
# negation.

-{T<:Towering}(m::T, n::T) = m + (-n)

### To implement reduction to lowest terms - seems to mean "extended
### Euclidean algorithm" which in turn involves "Euclidean division"
### which produces quotient and remainder. Does it produce gcd and the
### two irreducible factors? Then could also provide gcd, unless it
### seems to complicate the function. div(m, n) = q, r; best(f).

function sign{T<:Material}(m::Z{T})
    O, I = zero(Z{T}), one(Z{T})
    if m == O
        O
    elseif m < O
        -I
    else
        I
    end
end

function abs{T<:Material}(m::Z{T})
    O = zero(Z{T})
    if m >= O
        m
    else
        -m
    end
end

# "Division by repeated subtraction" adapted from
# https://en.wikipedia.org/wiki/Division_algorithm

function divrem{T<:Material}(n::Z{T}, d::Z{T})
    O, I = zero(Z{T}), one(Z{T})
    step(q::Z{T}, r::Z{T}) = if r >= d step(q + I, r - d) else (q, r) end
    if d == O
        (O, n)
    elseif d < O
        q, r = divrem(n, -d)
        (-q, r)
    elseif n < O
        q, r = divrem(-n, d)
        if r == O; (-q, O) else (-q - I, d - r) end
    else
        # n >= O, d > O
        step(O, n)
    end
end

div{T<:Material}(n::Z{T}, d::Z{T}) = ((q,r) = divrem(n, d); q)
rem{T<:Material}(n::Z{T}, d::Z{T}) = ((q,r) = divrem(n, d); r)

# Wants fld and mod, too. Because.

# Extended Euclidean algorithm computes gcd, Bezout coefficients, and
# the arguments in lowest terms, up to sign. Adapted from Wikipedia or
# some related source.

"""For strictly positive m, n only!"""
function euclidities{T<:Material}(m::Z{T}, n::Z{T})
    O, I = zero(Z{T}), one(Z{T})
    function step(r0, r1, s0, s1, t0, t1)
        q2, r2 = divrem(r0, r1)
        s2 = s0 - s1 * q2
        t2 = t0 - t1 * q2
        if r2 == O
            (r1, s1, t1, t2, s2)
        else
            step(r1, r2, s1, s2, t1, t2)
        end
    end
    step(m, n, I, O, O, I)
end

"""
    The greatest common divisor of the integers m and n.
    As a special case, gcd(O, O) == O.
    Otherwise gcd(m, n) > O.
"""
function gcd{T<:Material}(m::Z{T}, n::Z{T})
    O = zero(Z{T})
    if m == n == O
        O
    elseif m == O
        abs(n)
    elseif n == O
        abs(m)
    else
        g, a, b, w, u = euclidities(abs(m), abs(n))
        g
    end
end

function gcdx{T<:Material}(m::Z{T}, n::Z{T})
    O = zero(Z{T})
    if m == O || n == O
        (gcd(m, n), sign(m), sign(n))
    else
        g, a, b, w, u = euclidities(abs(m), abs(n))
        # *is* g ever negative here? surely not?
        (abs(g), sign(g) * sign(m) * a, sign(g) * sign(n) * b)
    end
end

"""(sign is on first)"""
function lowest{T<:Material}(m::Z{T}, n::Z{T})
    O = zero(Z{T})
    if m == O || n == O
        (sign(m), sign(abs(n)))
    else
        g, a, b, w, u = euclidities(abs(m), abs(n))
        (sign(m) * sign(n) * abs(w), abs(u))
    end
end
