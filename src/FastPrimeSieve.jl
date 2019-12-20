module FastPrimeSieve

const bit_1 = ~(0x01 << 7)
const bit_2 = ~(0x01 << 6)
const bit_3 = ~(0x01 << 5)
const bit_4 = ~(0x01 << 4)
const bit_5 = ~(0x01 << 3)
const bit_6 = ~(0x01 << 2)
const bit_7 = ~(0x01 << 1)
const bit_8 = ~(0x01 << 0)

const ps = (1, 7, 11, 13, 17, 19, 23, 29)

include("siever.jl")
include("handwritten_sieve.jl")
include("macrobased_sieve.jl")


end # module
