mutable struct Siever
    prime_div_30::Int

    # byte_index is the integer range 30(byte_index - 1) up to 30byte_index - 1
    byte_index::Int

    # Stores the next prime number to be crossed off. 
    # If `p` is the prime number and `q` the next multiple to be stored
    # Wheel index 8 * to_idx(p % 30) * to_idx(q % 30)
    wheel_index::Int

    function Siever(p::Int, segment_lo::Int)
        p² = p * p
        if p² >= segment_lo
            byte = p² ÷ 30 + 1

            # Wheel index stores both the index of the prime number mod 30
            # and the index of the active multiple. We start crossing off
            # p * p, so that would be to_idx(p % 30) twice. We combine those values
            # as a number between 1 ... 64.
            wheel = to_idx(p % 30)
            wheel_index = 8 * (wheel - 1) + wheel

            return new(p ÷ 30, byte, wheel_index)
        else
            # p * q will be the first number to cross off
            q, r = divrem(segment_lo, p)
            r != 0 && (q += 1)
            
            r_idx = 1
            byte = 1

            wheel_index = 1

            while true
                r = q % 30
                r_idx_maybe = findfirst(x -> x == r, ps)
                if r_idx_maybe !== nothing
                    r_idx = r_idx_maybe
                    break
                end
                q += 1
            end
                
            byte = p * q ÷ 30 + 1

            wheel_index = 8 * (to_idx(p % 30) - 1) + r_idx
            
            return new(p ÷ 30, byte, wheel_index)
        end
    end
end

function Base.show(io::IO, p::Siever)
    print(io, 30p.prime_div_30 + ps[(p.wheel_index - 1) ÷ 8 + 1], " (", p.byte_index, ", ", p.wheel_index, ")")
end

function advance!(p::Siever, byte_index, wheel_index)
    p.byte_index = byte_index
    p.wheel_index = wheel_index
end

# Generates all primes for sieving up to and including n
function generate_sievers(n)
    # hi should be ⌊√n⌋, but it would be nice to have hi + 1 == 0 mod 30.
    hi = 30ceil(Int, floor(Int, √n) / 30) - 1
    hihi = floor(Int, √hi)
    is_prime = trues(hi)

    primes = Siever[]

    @inbounds for i = 3:2:hihi
        if is_prime[i]
            for j = i*i:2i:hi
                is_prime[j] = false
            end
        end
    end

    @inbounds for i = 7:2:hi
        is_prime[i] && push!(primes, Siever(i, hi + 1))
    end

    return primes, hi + 1
end