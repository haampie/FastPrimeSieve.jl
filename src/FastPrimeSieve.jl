module FastPrimeSieve

const ps = (1, 7, 11, 13, 17, 19, 23, 29)

"""
Population count of a vector of UInt8s for counting prime numbers.
"""
function vec_count_ones(xs::Vector{UInt8}, n = length(xs))
    count = 0
    # Multiple of `sizeof(UInt64)` less than or equal to n
    bytes = n & -sizeof(UInt64)
    # Explanation: running `count_ones` on `UInt64` is faster than on `UInt8` because
    # `count_ones(::UInt8)` converts the output to `Int`, which kills the performance of
    # `count_ones`.  One could think of making `count::UInt8` and casting
    # `count_ones(x)%UInt8`, but that'd make it impossible to work on vectors with more than
    # 31 elements without overflowing, so we have to work with the wider type to get the
    # best performance and still get meaningful results.  Let's reinterpret as much as
    # possible of the vector as `UInt64`, on the rest runs `count_ones` without packing.
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
