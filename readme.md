# FastPrimeSieve.jl

## Features

- Uses O(2√n / log(n)) memory when discovering primes up to n. All prime numbers up to √n are stored.
- Skips multiples of 2, 3 and 5
- Exploits L1 cache by processing segment by segment (currently one segment is 32KB)
- Uses minimal memory: every byte represents an interval of 30 integers, meaning that all primes up to 1_000_000 can be sieved using just L1 cache.
- The sieving inner loop is unrolled such that 8 multiples can be removed per iteration.

## Current functionality

Counting prime numbers in an interval:

```julia
using FastPrimeSieve, BenchmarkTools

julia> @btime FastPrimeSieve.countprimes(2^32)
  1.507 s (13248 allocations: 477.91 KiB)
203280221
```

Note that it counts all primes in the range 1 ... 30⌈n/30⌉ - 1 at the moment, not exactly
up to an including `n`; the answer is correct ± 16.

## Limitations
Segmented sieving combined with loop unrolling while exploiting L1 cache is of course mostly
efficient when siever primes fit at least eight times in the segment. For example, with 32KB
of L1 cache, the siever primes should not exceed `30 num/byte * 32 * 1024 byte / 8 num = 122_880`, meaning we can efficiently sieve up to `n = 122_880^2 = 15_099_494_400 ≈ 2^34`. This package does not yet implement efficient methods that sieve in the range `2^34:∞`.

## What's next

Short term:
- Add a sensible, simple API that allows for iterating over prime numbers etc, such that
  this package can be contributed back to https://github.com/JuliaMath/Primes.jl.
- So far I've assumed the O(√n log log n) cost of finding siever primes is negligible, but
  for sieving in a small, constant interval `m:n` instead of `2:n` finding siever primes
  can be the bottleneck. It might make sense to recursively call the sieving procedure to
  obtain the siever primes.

Low-hanging fruit:
- Multithreading (should be fairly straighforward)

Long term:
- Improve performance in the range `2^34:∞`.
