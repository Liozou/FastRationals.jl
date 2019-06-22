##  __I am busy breaking, fixing, testing, and refining (June 17th--23rd)__

>  (  This will become available for use in concert with its announcement on Discourse.  )
>
> _please know that your interest and attentiveness are matters of moment and import_    

----
----

# FastRationals.jl

----

### rationals with unreal performance <sup>[𝓪](#source)</sup>

##### Copyright © 2017-2019 by Jeffrey Sarnoff. This work is released under The MIT License.
----

### using FastRationals


`FastRationals` exports two types: `FastQ32`, `FastQ64`, corresponding to `Rational{Int32}` and `Rational{Int64}`, respectively.
FastRationals are intended for use with _smaller_ rational values.  To compare two rationals or to calculate the sum, difference, product, or ratio of two rationals requires pairwise multiplication of the constituents of one by the constituents of the other.  Whether or not it overflow depends on the number of leading zeros (`leading_zeros`) in the binary representation of the absolute value of the numerator and the denominator given with each rational.  We really want the larger in magnitude of the numerator and denominator. This is the value that determines the number of bits available to form a product without overflowing. Looked at another way, this is the value that determines whether forming a product could possibly overflow. That is the information of most use in this context. It is alright to determine there is a possiblity of overflow where in fact no overflow will occur.  It is not alright to determine there is no possiblity of overflow where in fact overflow will occur.  In the first instance, some additional work will be done.  In the second instance, an overflow error would stop the computation.

```julia
bitsof(::Type{T}) where {T} = sizeof(T) * 8

maxmag(q::Rational{T}) where {T} = max(abs(q.num), abs(q.den))  # q.den != typemin(T)
maxbits(q::Rational{T}) where {T} = bitsof(T) - leading_zeros(maxmag(q))
maxbits(q1::Rational{T}, q2::Rational{T}) where {T} = maxbits(q1) + maxbits(q2)

mayoverflow(q1::Rational{T}, q2::Rational{T}) where {T} = bitsof(T) <= maxbits(q1, q2)
```
We simplify the expresssion for `mayoverflow` easily:
```
maxbits(q::T) where {T} = bitsof(T) - leading_zeros(maxmag(q))
maxbits(q1::T) + maxbits(q2::T) = 
       (bitsof(T) - leading_zeros(maxmag(q1))) + (bitsof(T) - leading_zeros(maxmag(q2)))
    =  (bitsof(T) + bitsof(T)) - (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2)))
    =  2*bitsof(T) - (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2)))
    
mayoverflow(q1::T, q2::T) = bitsof(T) <= maxbits(q1, q2) =
     bitsof(T) <= 2*bitsof(T) - (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2)))
   = (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2))) <= 2*bitsof(T) - bitsof(T)
   = (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2))) <= bitsof(T)
   
mayoverflow(q1::T, q2::T) where {T} =
    (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2))) <= bitsof(T)
```

FastRationals are at their most performant where overflow is absent or uncommon.  The converse holds, too: where overflow occurs very often, FastRationals have no intrinsic advantage to system Rationals.  How do we know what range of rational values are desireable?  A good place to start is to working with rational quantities that, taken in any pair, are such that `!mayoverflow(q1, q2)`.  As it is the nature of rational arithmetic to tend generate results increasing in their `maxmag`, it is prudent to constrain the range of rational values somewhat more.  Here is a table of desireable value ranges provided for your reference.


| FastQ32     |  range      | refinement  |
|-------------|-------------|-------------|
|             |             |             |
| desireable  |    ±511//1  |  ±1//511    |
|             |             |             |
| preferable  |  ±1_260//1  |  ±1//1_260  |
|             |             |             |
| admissible  | ±23_170//1  | ±1//23_170  |


| FastQ64     |  range         | refinement     |
|-------------|----------------|----------------|
|             |                |                |
| desireable  |    ±98_304//1  |  ±1//98_304    |
|             |                |                |
| preferable  |  ±524_288//1   |  ±1//524_288   |
|             |                |                |
| admissible  | ±2_097_152//1  | ±1//2_097_152  |




```julia
using FastRationals

```

### performance relative to system Rationals


With smaller rationals, arithmetic sequences run about 12x..16x faster.
With smaller rationals, matrix operations run about 2x..6x faster.

|  _small rationals_ |  Relative Speedup |
|:------------------------|:-----------------:|
|      mul/div            |       20          |
|      polyval            |       18          |
|      add/sub            |       15          |
|      4x4 matrix         |                   |
|      mul                |       10          |
|      lu                 |        5          | 
|      inv                |        3          |

----

### Benchmarking

```
using FastRationals, Polynomials, BenchmarkTools

w,x,y,z = Rational{Int32}.([1//12, -2//77, 3//54, -4//17]); q = Rational{Int32}(1//7);
a,b,c,d = FastRational.((w,x,y,z)); p = FastRational(q);

poly = Poly([w,x,y,z])
fastpoly = Poly([a,b,c,d])

polyval(poly, q) == polyval(fastpoly, p)
# true

relative_speedup =
    floor((@belapsed polyval($poly, $q)) / (@belapsed polyval($fastpoly, $p)))

# relative_speedup is ~16
```

```
using FastRationals, BenchmarkTools

x, y, z = Rational{Int32}.((1234//345, 345//789, 987//53))
a, b, c = FastRational.([x, y, z])

function test(x,y,z)
   a = x + y
   b = x * y
   c = z - b
   d = a / c
   return d
end

test(x,y,z) == test(a,b,c)
# true

relative_speedup =
    floor( (@belapsed test(Ref($x)[],Ref($y)[],Ref($z)[])) / 
           (@belapsed test(Ref($a)[],Ref($b)[],Ref($c)[])))

# relative_speedup is ~4
```

Arithmetic works like `Rational` for eltypes `Int8, .., Int128, UInt8, ..` except there is no Infinity, no NaN comparisons.

----

<sup><a name="source">[𝓪](#attribution)</a></sup> Harmen Stoppels on 2019-06-14
