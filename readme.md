# FastPrimeSieve.jl

## Features

- Uses O(2√n / log(n)) memory when discovering primes up to n. All prime numbers up to √n are stored.
- Skips multiples of 2, 3 and 5
- Exploits L1 cache by processing segment by segment (currently one segment is 32KB)
- Uses minimal memory: every byte represents an interval of 30 integers, meaning that all primes up to 1_000_000 can be sieved using just L1 cache.
- The sieving inner loop is unrolled such that 8 multiples can be removed per iteration.

## Current functionality

- Counting prime numbers in a large interval. Should be 10 to 16 times faster than Primes.jl
in the range `2^20:2^32`.

```julia
julia> using FastPrimeSieve, BenchmarkTools

julia> @btime FastPrimeSieve.countprimes(2^32)
  1.489 s (6 allocations: 187.86 KiB)
203280221
```

- Multithreaded prime counting in large intervals (set `JULIA_NUM_THREADS=n` where `n` is
  the number of threads).

```julia
# Ran on a cloud VM with 8 vCPUs and 128KB L1 cache
julia> @btime FastPrimeSieve.pcountprimes(2^32, segment_length = 128 * 1024, threads = 8)
  290.254 ms (173 allocations: 1.91 MiB)
203280221

julia> @btime FastPrimeSieve.pcountprimes(2^32, segment_length = 128 * 1024, threads = 4)
  359.990 ms (88 allocations: 1006.61 KiB)
203280221

julia> @btime FastPrimeSieve.pcountprimes(2^32, segment_length = 128 * 1024, threads = 2)
  710.347 ms (49 allocations: 528.06 KiB)
203280221

julia> @btime FastPrimeSieve.pcountprimes(2^32, segment_length = 128 * 1024, threads = 1)
  1.374 s (26 allocations: 285.03 KiB)
203280221
```

- Efficient iteration over prime numbers in the range `7:2^20` (2, 3, and 5 are skipped).
Should be roughly 6x faster than in Primes.jl.

```julia
julia> using FastPrimeSieve, BenchmarkTools

julia> @btime collect(FastPrimeSieve.SmallSieve(1_000_000))
  528.523 μs (5 allocations: 645.98 KiB)
78495-element Array{Int64,1}:
      7
     11
      ⋮
 999979
 999983
```

## Limitations
Segmented sieving combined with loop unrolling while exploiting L1 cache is of course mostly
efficient when siever primes fit at least eight times in the segment. For example, with 32KB
of L1 cache, the siever primes should not exceed `30 num/byte * 32 * 1024 byte / 8 num = 122_880`, meaning we can efficiently sieve up to `n = 122_880^2 = 15_099_494_400 ≈ 2^34`. This package does not yet implement efficient methods that sieve in the range `2^34:∞`.

## What's next

Short term:
- Add a sensible, simple API that allows for iterating over prime numbers etc, such that
  this package can be contributed back to https://github.com/JuliaMath/Primes.jl.
- Automatically use the right methods for the right range

Long term:
- Improve performance in the range `2^34:∞`.
