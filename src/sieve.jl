"""
For a prime number p and a multiple q, the wheel index encodes the prime number index of 
p and q modulo 30, which can be encoded to a single number from 1 ... 64. This allows us
to jump immediately into the correct loop at the correct offset.
"""
create_jump(wheel_index, i) = esc(:($wheel_index === $i && @goto $(Symbol(:x, i))))

"""
For any prime number `p` we compute its prime number index modulo 30 (here `wheel`) and we
generate the loop that crosses of the next 8 multiples that, modulo 30, are 
p * {1, 7, 11, 13, 17, 19, 23, 29}.
"""
function unrolled_loop(wheel)
    unrolled_loop_body = []
    labelname = Symbol(:x, 8 * (wheel - 1) + 1)
    p = ps[wheel]

    # First push the stopping criterion
    push!(unrolled_loop_body, esc(:(byte_idx > unrolled_max && break)))

    # Cross off the 8 next multiples
    for q in ps
        div, rem = divrem(p * q, 30)
        bit::UInt8 = ~(0x01 << (8 - to_idx(rem)))
        push!(unrolled_loop_body, esc(:(xs[byte_idx + increment * $(q - 1) + $div] &= $bit)))
    end

    # Increment the index
    push!(unrolled_loop_body, esc(:(byte_idx += increment * 30 + $p)))

    return quote
        $(esc(:(@label $labelname)))
        while true
            $(unrolled_loop_body...)
        end
    end
end

"""
The remainder of the loop for wheel index `wheel` that crosses off one multiple and checks
the loop condition afterwards.
"""
function loop_tail(wheel)
    tail_body = []

    # Our prime number modulo 30
    p = ps[wheel]

    ps_next = (1, 7, 11, 13, 17, 19, 23, 29, 31)
    for j in 1:8
        # Label name
        jump_idx = 8 * (wheel - 1) + j

        # Current multiplier modulo 30
        q = ps_next[j]

        # And the next multiplier
        q_next = ps_next[j + 1]

        div, rem = divrem(p * q, 30)

        # The bit mask for crossing off p * q
        bit::UInt8 = ~(0x01 << (8 - to_idx(rem)))

        # Compute the increments for the byte index for the next multiple
        incr_bytes = p * q_next ÷ 30 - div
        incr_multiple = q_next - q

        # Add a jump label, but skip the first one, because that is already above the
        # unrolled loop
        if j > 1
            push!(tail_body, esc(:(@label $(Symbol(:x, jump_idx)))))
        end
        
        push!(tail_body, esc(quote
            # Todo: find a better way to deal with this branch
            if byte_idx > n_bytes
                last_idx = $jump_idx
                @goto out
            end

            # Cross off the multiple
            xs[byte_idx] &= $bit

            # Increment the byte indexed to the index where the next multiple is located
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

function sieve(n; segment_length = 1024 * 32)
    # First compute all prime numbers up to approximately sqrt(n)
    sievers, segment_start = generate_sievers(n)

    last_byte = ceil(Int, n / 30)

    # Then compute the first segment index
    segment_index_start = segment_start ÷ 30 + 1

    # Now create a chunk.
    xs = Vector{UInt8}(undef, segment_length)

    count = 3 + length(sievers)

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