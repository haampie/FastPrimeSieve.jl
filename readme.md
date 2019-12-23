# FastPrimeSieve.jl

Basic features:

- Memory usage is O(2√n / log(n)), assuming O(1) primes are saved
- Skips multiple of 2, 3 and 5
- Exploits L1 cache by processing segment by segment (currently one segment is 32KB)
- Efficient bitpacking: every byte represents an interval of 30 integers, meaning that all
  primes up till 1_000_000 can be sieved using just L1 cache.
- The sieving inner loop is unrolled such that 8 multiples can be removed per iteration.

Current functionality is just counting prime numbers:

```julia
using FastPrimeSieve, BenchmarkTools

julia> @btime FastPrimeSieve.sieve(1_000_000_000)
  266.732 ms (6923 allocations: 261.77 KiB)
50847536
```

Note that it counts all primes in the range 1 ... 30⌈n/30⌉ - 1 at the moment, not exactly
up to an including `n`.

Next steps:

- Add multithreading
- Add a sensible API that allows iteration
