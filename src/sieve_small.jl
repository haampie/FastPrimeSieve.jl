function small_sieve(n)
    # Unrolled loop without segments
    last_byte = cld(n, 30)
    xs = Vector{UInt8}(undef, last_byte)
    fill!(xs, 0xFF)

    # Ensure `1` is not a prime number
    @inbounds xs[1] &= wheel_mask(1)

    # And ensure numbers > n are not prime since we are not considering them
    @inbounds for i = 1 : 8
        if n < 30 * (last_byte - 1) + ps[i]
            xs[last_byte] &= wheel_mask(ps[i])
        end
    end

    offset = 0

    @inbounds for i = 1 : length(xs)
        x = xs[i]
        while x != 0x00
            # The next prime number
            p = offset + ps[trailing_zeros(x) + 0x01]

            # Are we done yet?
            p² = p * p
            p² > n && @goto done
            
            # Otherwise cross off multiples of p starting at p²
            byte_idx  = p² ÷ 30 + 1
            wheel     = to_idx(p % 30)
            wheel_idx = 8 * (wheel - 1) + wheel
            n_bytes   = last_byte
            increment = i - 1
            @sieve_loop :unroll # Just unroll -- no segmented business here
            x &= x - 0x01
        end
        offset += 30
    end

    @label done

    return xs
end

function small_primes(n)
    n < 2 && return Int[]
    n < 3 && return [2]
    n < 5 && return [2, 3]
    n < 7 && return [2, 3, 5]

    xs = small_sieve(n)
    primes = Int[2, 3, 5]

    offset = 0
    @inbounds for x in xs
        while x != 0x00
            push!(primes, offset + ps[trailing_zeros(x) + 0x01])
            x &= x - 0x01
        end
        offset += 30
    end

    primes
end