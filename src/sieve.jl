"""
For a prime number p and a multiple q, the wheel index encodes the prime number index of 
p and q modulo 30, which can be encoded to a single number from 1 ... 64. This allows us
to jump immediately into the correct loop at the correct offset.
"""
create_jump(wheel_index, i) = esc(:($wheel_index === $i && @goto $(Symbol(:x, i))))

wheel_mask(prime_mod_30)::UInt8 = ~(0x01 << (8 - to_idx(prime_mod_30)))

"""
For any prime number `p` we compute its prime number index modulo 30 (here `wheel`) and we
generate the loop that crosses of the next 8 multiples that, modulo 30, are 
p * {1, 7, 11, 13, 17, 19, 23, 29}.
"""
function unrolled_loop(wheel)
    p = ps[wheel]
    unrolled_loop_body = []

    # First push the stopping criterion
    push!(unrolled_loop_body, esc(:(byte_idx > unrolled_max && break)))

    # Cross off the 8 next multiples
    for q in ps
        div, rem = divrem(p * q, 30)
        bit = wheel_mask(rem)
        push!(unrolled_loop_body, esc(:(xs[byte_idx + increment * $(q - 1) + $div] &= $bit)))
    end

    # Increment the byte index to where the next / 9th multiple is located
    push!(unrolled_loop_body, esc(:(byte_idx += increment * 30 + $p)))

    return quote
        $(esc(:(@label $(Symbol(:x, 8 * (wheel - 1) + 1)))))
        while true
            $(unrolled_loop_body...)
        end
    end
end

"""
The `loop_tail`
"""
function loop_tail(wheel)
    tail_body = []

    # Our prime number modulo 30
    p = ps[wheel]

    ps_next = (1, 7, 11, 13, 17, 19, 23, 29, 31)
    for j in 1:8
        # Label name
        jump_idx = 8 * (wheel - 1) + j

        # Current and next multiplier modulo 30
        q_curr = ps_next[j]
        q_next = ps_next[j + 1]

        # Get the bit mask for crossing off p * q_curr
        div_curr, rem_curr = divrem(p * q_curr, 30)
        bit = wheel_mask(rem_curr)

        # Compute the increments for the byte index for the next multiple
        incr_bytes = p * q_next ÷ 30 - div_curr
        incr_multiple = q_next - q_curr

        # Add a jump label, but skip the first one, because that is already above the
        # unrolled loop
        if j > 1
            push!(tail_body, esc(:(@label $(Symbol(:x, jump_idx)))))
        end
        
        push!(tail_body, esc(quote
            # Todo: this if generates an extra jump, maybe conditional moves are possible?
            if byte_idx > n_bytes
                last_idx = $jump_idx
                @goto out
            end

            # Cross off the multiple
            xs[byte_idx] &= $bit

            # Increment the byte index to where the next multiple is located
            byte_idx += increment * $incr_multiple + $incr_bytes 
        end))
    end

    return quote
        $(tail_body...)
    end
end

function full_loop(wheel)
    quote
        while true
            $(unrolled_loop(wheel))
            $(loop_tail(wheel))
        end
    end
end

macro sieve_loop(siever, byte_start, byte_next_start)
    # When crossing off p * q where `p` is the siever prime and `q` the current multiplier
    # we have that p and q are {1, 7, 11, 13, 17, 19, 23, 29} mod 30.
    # For each of these 8 possibilities for `p` we create a loop, and per loop we
    # create 8 entrypoints to jump into. The first entrypoint is the unrolled loop for
    # whenever we can remove 8 multiples at the same time when all 8 fit in the interval
    # between byte_start:byte_next_start-1. Otherwise we can only remove one multiple at
    # a time. With 8 loops and 8 entrypoints per loop we have 64 different labels, numbered
    # x1 ... x64.

    # As an example, take p = 7 as a prime number and q = 23 as the first multiplier, and
    # assume our number line starts at 1 (so byte 1 represents 1:30, byte 2 represent 31:60). 
    # We have to cross off 7 * 23 = 161 first, which has byte index 6. Our prime number `p`
    # is in the 2nd spoke of the wheel and q is in the 7th spoke. This means we have to jump
    # to the 7th label in the 2nd loop; that is label 8 * (2 - 1) + 7 = 15. There we cross 
    # off the multiple (since 161 % 30 = 11 is the 3rd spoke, we "and" the byte with 0b11011111)
    # Then we move to 7 * 29 (increment the byte index accordingly), cross it off as well.
    # And now we enter the unrolled loop where 7 * {31, 37, ..., 59} are crossed off, then 
    # 7 * {61, 67, ..., 89} etc. Lastly we reach the end of the sieving interval, we cross
    # off the remaining multiples one by one, until the byte index is passed the end.
    # When that is the case, we save at which multiple / label we exited, so we can jump
    # there without computation when the next interval of the number line is sieved.

    jump_table = [create_jump(:wheel_idx, i) for i = 1 : 64]
    loops = [full_loop(wheel) for wheel in 1 : 8]

    quote
        $(esc(:(n_bytes      = $byte_next_start - $byte_start)))
        $(esc(:(byte_idx     = $siever.byte_index - $byte_start + 1)))
        $(esc(:(wheel_idx    = $siever.wheel_index)))
        $(esc(:(increment    = $siever.prime_div_30)))
        $(esc(:(unrolled_max = n_bytes - increment * 28 - 28)))

        # Create jumps inside loops
        $(esc(:(last_idx = 0)))
        $(jump_table...)

        # Create loops
        $(loops...)

        # Update the index when at the end of a segment
        $(esc(:(@label out)))
        $(esc(:(advance!(p, $byte_start + byte_idx - 1, last_idx))))
    end
end

"""
Population count of a vector of UInt8s for counting prime numbers.
See https://github.com/JuliaLang/julia/issues/34059
"""
function vec_count_ones(xs::Vector{UInt8}, n)
    count = 0
    chunks = n ÷ sizeof(UInt)
    GC.@preserve xs begin
        ptr = Ptr{UInt}(pointer(xs))
        for i in 1:chunks
            count += count_ones(unsafe_load(ptr, i))
        end
    end

    @inbounds for i in 8chunks+1:n
        count += count_ones(xs[i])
    end

    count
end

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
            @sieve_loop p segment_index_start segment_index_next
        end

        count += vec_count_ones(xs, segment_index_next - segment_index_start)

        segment_index_start += segment_length
    end

    return count
end