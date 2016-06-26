using Tower
using Base.Test

type countertype
  pass::UInt
  fail::UInt
end
counter = countertype(0, 0)

function verbose_handler(r::Test.Success)
    counter.pass += 1
    println("PASS ", r.expr)
end
function verbose_handler(r::Test.Failure)
    counter.fail += 1
    println("FAIL ", r.expr, " : ", r.resultexpr)
end
verbose_handler(r::Test.Error) = rethrow(r)

silent_handler(r::Test.Success) = counter.pass += 1
silent_handler(r::Test.Failure) = counter.fail += 1
silent_handler(r::Test.Error) = rethrow(r)

function peanoid{T}(::Type{T})
    O = zero(T)
    I = one(T)
    @test O + I == I + O == I
    @test O * I == I * O == O
    @test I + (I + I) == (I + I) + I
end
Test.with_handler(silent_handler) do
    peanoid(Halves)
    peanoid(Z{Halves})
    peanoid(Q{Halves})
    peanoid(C{Z{Halves}})
    peanoid(C{Q{Halves}})
end

function ordered{T<:Towering}(::Type{T})
    O, I = zero(T), one(T)
    @test zero(T) == zero(T)
    @test one(T) == one(T)
    @test O <= O
    @test O >= O
    @test I <= I
    @test I >= I
    @test O != I != I + I != O
    @test O < I < I + I <= I + I
    @test I + I >= I + I > I > O
end
Test.with_handler(silent_handler) do
    ordered(Halves)
    ordered(Z{Tallies})
    ordered(Q{Tallies})
    ordered(C{Z{Tallies}}) # these particular values ...
    ordered(C{Q{Tallies}}) # ... in this particular order
end

"2^3 is almost 3^2 but not quite - what gives?"
function funny{T<:Towering,U<:Material}(::Type{T}, ::Type{U})
    I, J = one(T), one(U)
    @test (I + I)^(J + J + J) + I == (I + I + I)^(J + J)
end
Test.with_handler(silent_handler) do
    funny(Halves, Halves)
    funny(Z{Positives}, Tallies)
    funny(Q{Tallies}, Tallies)
    funny(C{Z{Tallies}}, Naturals)
    funny(C{Q{Tallies}}, Naturals)
end

"x^2 + 2x + 1 == (x + 1)^2 == (x + 1) (x + 1)"
function polynomial{T<:Towering,U<:Material}(x::T, ::Type{U})
    I = one(T)
    ii = next(one(U))
    f(x) = x^ii + (I + I) * x + I
    g(x) = (x + I)^ii
    h(x) = (x + I) * (x + I)
    @test f(x) == g(x) == h(x)
end
Test.with_handler(silent_handler) do
    let O = zero(Halves), I = one(Halves)
        polynomial(O, Tallies)
        polynomial(I, Tallies)
        polynomial(I + I, Tallies)
    end
    let O = zero(Z{Inverses}), I = one(Z{Inverses})
        polynomial(O, Tallies)
        polynomial(I, Tallies)
        polynomial(I + I, Tallies)
        polynomial(-I, Tallies)
    end
    let O = zero(Q{Positives}), I = one(Q{Positives})
        polynomial(O, Tallies)
        polynomial(I, Tallies)
        polynomial(I + I, Tallies)
        polynomial(-I, Tallies)
    end
 
   let O = zero(C{Z{Naturals}}), I = one(C{Z{Naturals}})
       polynomial(O, Naturals)
       polynomial(I, Naturals)
       polynomial(I + I, Naturals)
       polynomial(-I, Naturals)
   end
end

function absolute{T<:Towering}(::Type{T})
    O, I = zero(T), one(T)
    II, III = I + I, I + I + I
    @test sign(O) == O
    @test sign(I) == I
    @test sign(II) == I
    @test sign(-I) == -I
    @test sign(-II) == -I
    @test abs(O) == O
    @test abs(I) == I
    @test abs(II) == II
    @test abs(-I) == I
    @test abs(-II) == II
end
Test.with_handler(silent_handler) do
    absolute(Z{Naturals})
end

function negative{T<:Towering}(::Type{T})
    O, I = zero(T), one(T)
    II, III = I + I, I + I + I
    @test O - I == -I
    @test I - O == I
    @test I - I == O
    @test I + -I == O
    @test I * -I == -I
    @test -I * -I == I
    @test II - O == II
    @test II - I == I
    @test II - II == O
    @test II - III == -I
    @test O - II == -II
    @test O + -II == -II
    @test O - (O - II) == II
    @test I - (I - II) == II
    @test -(-I) == I
    @test -(-II) == II
    @test -O == O
    @test -I < O
    @test -I < I
    @test -II < O
    @test -II < I
end
Test.with_handler(silent_handler) do
    negative(Z{Positives})
    negative(Q{Positives})
    negative(C{Z{Tallies}})
    negative(C{Z{Tallies}})
end

function euclidean{T<:Towering}(::Type{T})
    o, i = zero(T), one(T)
    ii = i + i
    iii = ii + i
    iv = iii + i
    v = iv + i
    X = [o, i, ii, iii, iv, v]
    for m in X, n in X
        q, r = divrem(m, n)
        @test m == q * n + r
	# no can check o <= r < n || (r == m && n == q == o)
	# because not implemented <=, < [except have now]
    end
end
Test.with_handler(silent_handler) do
    # euclidean(Tallies) -- needs floor.jl included in Tower
    euclidean(Z{Naturals})
end

# Not sure if Material types need be Euclidean at all but leave the
# above for now and introduce a more important set of "divisible"
# tests for signed integer types (Bézout, see)

function divisible{T}(::Type{T})
    O, I = zero(Z{T}), one(Z{T})
    II = I + I
    III = II + I
    IV = III + I
    VI = IV + II
    for m in [-VI, -IV, -III, -II, -I, O, I, II, III, IV, VI],
        n in [-VI, -IV, -III, -II, -I, O, I, II, III, IV, VI]

        q, r = divrem(m, n)
        @test m == q*n + r

        # also have bounds on r

        g = gcd(m, n)
        d, a, b = gcdx(m, n)
	@test g == d
        w, u = lowest(m, n)
        @test g == a * m + b * n >= O
        @test u >= O
        @test m == (n < O ? -w * g : w * g)
        @test n == (n < O ? -u * g : u * g)
        @test gcd(w, u) == (w == u == O ? O : I)
        @test m * u == w * n
    end
end
Test.with_handler(silent_handler) do
    divisible(Tallies)
end

function reasonable{T<:Towering}(::Type{T})
    I = one(T)
    II = I + I
    III = I + I + I
    @test III * (I / III) == I
    @test -III * (I / -III) == I
    @test I / I == I
    @test II / II == I
    @test I / (I / II) == II
    @test I / (I / -III) == -III
    @test III / (I / II) == III * II
    @test -III / (I / II) == -III * II
    @test I/II + I/II == I
    @test I/III + II/III == I
    @test I/II + I == III/II
    @test I/II + I/III == I - I/(III + III)
end
Test.with_handler(silent_handler) do
    reasonable(Q{Tallies})
    reasonable(C{Q{Tallies}})
end

function unreasonable{T<:Towering}(::Type{T})
    O, I = zero(T), one(T)
    o, i = zero(Tallies), one(Tallies)
    II = I + I
    @test isnan(I/O)
    @test isnan(O/O)
    @test isnan((-I)/O)
    @test isnan(-(I/O))
    @test isnan(O/O - O/O)
    @test isnan(I/(I/O))
    @test isnan(I + (I/O))
    @test isnan(I * (I/O))
    @test I/O == I/O
    @test !(I/O != I/O)
    @test !(I/O < I/O)
    @test !(I/O > I/O)
    @test I/O <= I/O
    @test I/O >= I/O

    @test (I/O)^o == I
    @test isnan((I/O)^i)
end
Test.with_handler(silent_handler) do
    unreasonable(Q{Tallies})
    unreasonable(C{Q{Tallies}})
end

if counter.fail == 0
    info("Tests PASS: ", counter.pass)
    info("All tests pass")
elseif counter.pass == 0
    info("No tests run")
else
    info("Tests PASS: ", counter.pass)
    info("Tests FAIL: ", counter.fail)
    info("Some tests pass")
end
