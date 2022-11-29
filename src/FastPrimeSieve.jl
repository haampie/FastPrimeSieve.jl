module FastPrimeSieve

const ps = (1, 7, 11, 13, 17, 19, 23, 29)

"""
Population count of a vector of UInt8s for counting prime numbers.
"""
function vec_count_ones(xs::Vector{UInt8}, n = length(xs))
    count = 0
    # Multiple of `sizeof(UInt64)` less than or equal to n
    bytes = n & -sizeof(UInt64)
    # Running `count_ones` on `UInt64` can be vectorised much better than on
    # `UInt8`.  Let's reinterpret as much as possible of the vector as `UInt64`,
    # on the rest runs `count_ones` without packing.
    xs64 = reinterpret(UInt64, @inbounds(@view(xs[1:bytes])))
    @simd for x in xs64
        count += count_ones(x)
    end
    # Remainder of the vector which doesn't fit into a `UInt64`.
    @simd for idx in (bytes + 1):n
        count += @inbounds count_ones(xs[idx])
    end
    return count
end

function to_idx(x)
    x ==  1 && return 1
    x ==  7 && return 2
    x == 11 && return 3
    x == 13 && return 4
    x == 17 && return 5
    x == 19 && return 6
    x == 23 && return 7
    return 8
end

include("generate_sieving_loop.jl")
include("sieve_small.jl")
include("presieve.jl")
include("siever.jl")
include("sieve.jl")
include("parallel.jl")

end # module
