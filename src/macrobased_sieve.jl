macro jumps(idx)
    list = []
    for i = 1 : 64
        name = Symbol(:x, i)
        push!(list, esc(:($idx === $i && @goto $name)))
    end
    quote $(list...) end
end

macro sieve_loop(i)
    ids(p) = findfirst(x -> x === p, ps)

    current_prime_idx::Int = ids(i)

    label_start = 8 * (current_prime_idx - 1) + 1
    firstlabelname = Symbol(:x, label_start)

    unrolled_loop_body = []

    # First push the stopping criterion
    push!(unrolled_loop_body, esc(:(byte_idx > unrolled_max && break)))

    # Cross off the 8 next multiples
    for p in ps
        d, r = divrem(i * p, 30)
        bit = Symbol(:bit_, ids(r))
        push!(unrolled_loop_body, esc(quote
            xs[byte_idx + increment * $(p - 1) + $d] &= $bit
        end))
    end

    # Increment the index
    push!(unrolled_loop_body, esc(:(byte_idx += increment * 30 + $i)))

    # The tail
    tail_body = []

    ps_next = (7, 11, 13, 17, 19, 23, 29, 31)
    for j in 1:8
        d, r = divrem(i * ps[j], 30)
        dd,  = divrem(i * ps_next[j], 30)
        bit = Symbol(:bit_, ids(r))

        step = dd - d
        stepp = ps_next[j] - ps[j]

        if j > 1
            labelname = Symbol(:x, label_start + j - 1)
            push!(tail_body, :($(esc(:(@label $labelname)))))
        end
        
        push!(tail_body, esc(quote
            if byte_idx > n_bytes
                advance!(p, segment_index_start + byte_idx - 1, $(label_start + j - 1))
                @goto out
            end
            xs[byte_idx] &= $bit
            byte_idx += increment * $stepp + $step 
        end))
    end
    
    return quote
        while true
            $(esc(:(@label $firstlabelname)))
            while true
                $(unrolled_loop_body...)
            end
            $(tail_body...)
        end
    end
end

function macrobased_sieve(n)
    # First compute all prime numbers up to approximately sqrt(n)
    sievers, segment_start = generate_sievers(n)

    last_byte = ceil(Int, n / 30)

    # Then compute the first segment index
    segment_length = 1024 * 32 # approx L1 cache size, maybe play around a bit with this?
    segment_index_start = segment_start ÷ 30 + 1

    # Now create a chunk.
    xs = Vector{UInt8}(undef, segment_length)

    count = 3 + length(sievers)

    @inbounds while segment_index_start <= last_byte
        fill!(xs, 0xFF)

        segment_index_next = min(segment_index_start + segment_length, last_byte + 1)

        n_bytes = segment_index_next - segment_index_start

        for p in sievers
            byte_idx = p.byte_index[] - segment_index_start + 1
            wheel_idx = p.wheel_index[]
            increment = p.prime_div_30
            unrolled_max = n_bytes - increment * 28 - 28

            @jumps wheel_idx
            @sieve_loop 1
            @sieve_loop 7
            @sieve_loop 11
            @sieve_loop 13
            @sieve_loop 17
            @sieve_loop 19
            @sieve_loop 23
            @sieve_loop 29

            @label out
        end

        for i = 1 : n_bytes
            count += count_ones(xs[i])
        end

        segment_index_start += segment_length
    end

    return count
end