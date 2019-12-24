# FastPrimeSieve.jl

## Features

- Memory usage is O(2√n / log(n)), assuming O(1) primes are saved
- Skips multiple of 2, 3 and 5
- Exploits L1 cache by processing segment by segment (currently one segment is 32KB)
- Efficient bitpacking: every byte represents an interval of 30 integers, meaning that all
  primes up till 1_000_000 can be sieved using just L1 cache.
- The sieving inner loop is unrolled such that 8 multiples can be removed per iteration.


## Limitations
Segmented sieving combined with loop unrolling while exploiting L1 cache is of course mostly
efficient when siever primes fit 8 times in the segment. So with 32KB of cache, the siever
primes should not exceed `30 * 32 * 1024 / 8 = 122_880`, meaning we can efficiently sieve
up to `n = 15_099_494_400 ≈ 2^34`. This package does not yet implement efficient methods
that sieve in the range `2^34:∞`.

## Current functionality

Counting prime numbers in an interval:

```julia
using FastPrimeSieve, BenchmarkTools

julia> @btime FastPrimeSieve.countprimes(2^32)
  1.507 s (13248 allocations: 477.91 KiB)
203280221
```

Note that it counts all primes in the range 1 ... 30⌈n/30⌉ - 1 at the moment, not exactly
up to an including `n`.

## What's next

Short term:
- Add a sensible, simple API that allows for iterating over prime numbers etc, such that
package can be contributed back to https://github.com/JuliaMath/Primes.jl.

Low-hanging fruit:
- Multithreading (should be fairly straighforward)

Long term:
- Improve performance in the range `2^34:∞`.
