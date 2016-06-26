"""
    A family of numeric towers built on different material pairs of zero
    and next, with equality based ultimately on the material type. This
    is a simple conceptual exercise and *not intended as practical*.
"""

module Tower

# need <= imported any more? that was when NaN did not equal NaN

import Base: zero, one, next, ==, isless, <=, isnan
import Base: +, *, ^, -, /
import Base: div, rem, divrem, fld, mod, fldmod
import Base: gcd, gcdx, abs, sign
import Base: real, imag

export Towering, Simple, Whole, Material
export Halves, Inverses, Naturals, Positives, Tallies
export Z, Q, C

export lowest # or not export? should not be

abstract Towering
abstract Simple <: Towering
abstract Whole <: Simple
abstract Material <: Whole

include("N.jl") # the material types

include("Z.jl")

include("Q.jl")

include("C.jl")

end
