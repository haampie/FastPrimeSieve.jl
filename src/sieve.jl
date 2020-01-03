countprimes(to; segment_length = 1024 * 32) = countprimes(1, to, segment_length)

function generate_siever_primes(small_sieve::SmallSieve, segment_lo)
    xs = small_sieve.xs
    sievers = Vector{Siever}(undef, vec_count_ones(xs))
    j = 0
    @inbounds for i = eachindex(xs)
        x = xs[i]
        while x != 0x00
            sievers[j += 1] = Siever(compute_prime(x, i), segment_lo)
            x &= x - 0x01
        end
    end
    return sievers
end

function countprimes(from, to, segment_length = 1024 * 32)
    # 1 is not a prime number anyway
    from = max(from, 2)

    first_byte = cld(from, 30)
    last_byte = cld(to, 30)

    sievers = generate_siever_primes(SmallSieve(isqrt(to)), 30 * (first_byte - 1) + 1)
    small_buffer = create_presieve_buffer()

    # Now create a chunk.
    xs = Vector{UInt8}(undef, segment_length)

    segment_index_start = first_byte
    
    count = if from <= 2
        3
    elseif from <= 5
        2
    elseif from <= 7
        1
    else
        0
    end

    @inbounds while segment_index_start <= last_byte
        segment_index_next = min(segment_index_start + segment_length, last_byte + 1)
        segment_curr_len = segment_index_next - segment_index_start

        # Presieve
        # fill!(xs, 0xFF)
        apply_presieve_buffer!(xs, small_buffer, segment_index_start, segment_index_next - 1)

        # @show vec_count_ones(xs, segment_curr_len)

        # Set the preceding so many bits before `from` to 0
        if segment_index_start == first_byte
            if first_byte === 1
                xs[1] = 0b11111110 # just make 1 not a prime.
            end
            for i = 1 : 8
                30 * (segment_index_start - 1) + ps[i] >= from && break
                xs[1] &= wheel_mask(ps[i])
            end
        end

        # Set the remaining so many bits after `to` to 0
        if segment_index_next == last_byte + 1
            for i = 8 : -1 : 1
                to >= 30 * (segment_index_next - 2) + ps[i] && break
                xs[segment_curr_len] &= wheel_mask(ps[i])
            end
        end

        # Sieve the interval, but skip the pre-sieved primes
        for p_idx in 5:length(sievers)
            p            = sievers[p_idx]
            last_idx     = 0
            n_bytes      = segment_index_next - segment_index_start
            byte_idx     = p.byte_index - segment_index_start + 1
            wheel_idx    = p.wheel_index
            increment    = p.prime_div_30
            @sieve_loop :unroll :save_on_exit
            sievers[p_idx] = Siever(increment, segment_index_start + byte_idx - 1, last_idx)
        end

        count += vec_count_ones(xs, segment_curr_len)

        segment_index_start += segment_length
    end

    return count
end