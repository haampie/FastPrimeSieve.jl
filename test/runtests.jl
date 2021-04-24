using Test

using FastPrimeSieve: countprimes, pcountprimes

@test countprimes(100) == 25
@test countprimes(2^31) == 105097565
@test pcountprimes(2^31, threads=2) == 105097565