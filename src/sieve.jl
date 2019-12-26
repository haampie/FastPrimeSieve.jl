countprimes(to; segment_length = 1024 * 32) = countprimes(0, to, segment_length = segment_length)

function countprimes(from, to; segment_length = 1024 * 32)
    # Assume to > 5

    # For sieving the interval from:to we need all prime numbers up to and including ⌊√to⌋.
    # But for simplicity we go over the full byte where ⌊√n⌋ is located in; that is
    # we find all prime numbers in 1:30cld(⌊√n⌋, 30)-1.
    last_siever_byte_index = cld(floor(Int, √to), 30)
    siever_upperbound = 30 * last_siever_byte_index
    
    # Start sieving at from, or a bit later when siever primes are overlapping
    segment_index_start = max(cld(from, 30), last_siever_byte_index + 1)
    
    sievers = generate_sievers(siever_upperbound, 30 * (segment_index_start - 1) + 1)
    
    last_byte = cld(to, 30)

    # Now create a chunk.
    xs = Vector{UInt8}(undef, segment_length)

    # Find `from` in the siever primes.
    # We don't deal with overlap between `from` and `siever_upperbound` yet.
    count = from > siever_upperbound ? 0 : 3 + length(sievers)

    @inbounds while segment_index_start <= last_byte
        fill!(xs, 0xFF)

        segment_index_next = min(segment_index_start + segment_length, last_byte + 1)

        for p in sievers
            last_idx     = 0
            n_bytes      = segment_index_next - segment_index_start
            byte_idx     = p.byte_index - segment_index_start + 1
            wheel_idx    = p.wheel_index
            increment    = p.prime_div_30
            @sieve_loop :unroll :save_on_exit
            advance!(p, segment_index_start + byte_idx - 1, last_idx)
        end

        count += vec_count_ones(xs, segment_index_next - segment_index_start)

        segment_index_start += segment_length
    end

    return count
end