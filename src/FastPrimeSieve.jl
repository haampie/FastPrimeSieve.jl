module FastPrimeSieve

const ps = (1, 7, 11, 13, 17, 19, 23, 29)

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

include("siever.jl")
include("sieve.jl")


end # module
