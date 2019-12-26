countprimes(to; segment_length = 1024 * 32) = countprimes(1, to, segment_length = segment_length)

function countprimes(from, to; segment_length = 1024 * 32)
    # 1 is not a prime number anyway
    from = max(from, 2)

    first_byte = cld(from, 30)
    last_byte = cld(to, 30)

    sievers_iterator = SmallSieve(isqrt(to))
    sievers = Vector{Siever}(undef, length(sievers_iterator))

    @inbounds for (i, p) in enumerate(sievers_iterator)
        sievers[i] = Siever(p, 30 * (first_byte - 1) + 1)
    end

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
        fill!(xs, 0xFF)

        segment_index_next = min(segment_index_start + segment_length, last_byte + 1)
        segment_curr_len = segment_index_next - segment_index_start

        # Set the preceding so many bits before `from` to 0
        if segment_index_start == first_byte
            @inbounds for i = 1 : 8
                if 30 * (segment_index_start - 1) + ps[i] < from
                    xs[1] &= wheel_mask(ps[i])
                end
            end
        end

        # Set the remaining so many bits after `to` to 0
        if segment_index_next == last_byte + 1
            @inbounds for i = 1 : 8
                if to < 30 * (segment_curr_len - 1) + ps[i]
                    xs[segment_curr_len] &= wheel_mask(ps[i])
                end
            end
        end

        for p in sievers
            last_idx     = 0
            n_bytes      = segment_index_next - segment_index_start
            byte_idx     = p.byte_index - segment_index_start + 1
            wheel_idx    = p.wheel_index
            increment    = p.prime_div_30
            @sieve_loop :unroll :save_on_exit
            advance!(p, segment_index_start + byte_idx - 1, last_idx)
        end

        count += vec_count_ones(xs, segment_curr_len)

        segment_index_start += segment_length
    end

    return count
end