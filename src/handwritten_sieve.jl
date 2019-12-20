function handwritten_sieve(n)
    # First compute all prime numbers up to approximately sqrt(n)
    sievers, segment_start = generate_sievers(n)

    last_byte = ceil(Int, n / 30)

    # Then compute the first segment index
    segment_length = 1024 * 32 # approx L1 cache size, maybe play around a bit with this?
    segment_index_start = segment_start ÷ 30 + 1

    # Now create a chunk.
    xs = Vector{UInt8}(undef, segment_length)

    count = 3 + length(sievers)

    @inbounds while true
        segment_index_start > last_byte && break

        fill!(xs, 0xFF)

        segment_index_next = min(segment_index_start + segment_length, last_byte + 1)

        n_bytes = segment_index_next - segment_index_start

        for p in sievers
            byte_idx = p.byte_index[] - segment_index_start + 1
            wheel_idx = p.wheel_index[]
            increment = p.prime_div_30
            unrolled_max = n_bytes - increment * 28 - 28

            wheel_idx ===  1 && @goto  x1
            wheel_idx ===  2 && @goto  x2
            wheel_idx ===  3 && @goto  x3
            wheel_idx ===  4 && @goto  x4
            wheel_idx ===  5 && @goto  x5
            wheel_idx ===  6 && @goto  x6
            wheel_idx ===  7 && @goto  x7
            wheel_idx ===  8 && @goto  x8
            wheel_idx ===  9 && @goto  x9
            wheel_idx === 10 && @goto x10
            wheel_idx === 11 && @goto x11
            wheel_idx === 12 && @goto x12
            wheel_idx === 13 && @goto x13
            wheel_idx === 14 && @goto x14
            wheel_idx === 15 && @goto x15
            wheel_idx === 16 && @goto x16
            wheel_idx === 17 && @goto x17
            wheel_idx === 18 && @goto x18
            wheel_idx === 19 && @goto x19
            wheel_idx === 20 && @goto x20
            wheel_idx === 21 && @goto x21
            wheel_idx === 22 && @goto x22
            wheel_idx === 23 && @goto x23
            wheel_idx === 24 && @goto x24
            wheel_idx === 25 && @goto x25
            wheel_idx === 26 && @goto x26
            wheel_idx === 27 && @goto x27
            wheel_idx === 28 && @goto x28
            wheel_idx === 29 && @goto x29
            wheel_idx === 30 && @goto x30
            wheel_idx === 31 && @goto x31
            wheel_idx === 32 && @goto x32
            wheel_idx === 33 && @goto x33
            wheel_idx === 34 && @goto x34
            wheel_idx === 35 && @goto x35
            wheel_idx === 36 && @goto x36
            wheel_idx === 37 && @goto x37
            wheel_idx === 38 && @goto x38
            wheel_idx === 39 && @goto x39
            wheel_idx === 40 && @goto x40
            wheel_idx === 41 && @goto x41
            wheel_idx === 42 && @goto x42
            wheel_idx === 43 && @goto x43
            wheel_idx === 44 && @goto x44
            wheel_idx === 45 && @goto x45
            wheel_idx === 46 && @goto x46
            wheel_idx === 47 && @goto x47
            wheel_idx === 48 && @goto x48
            wheel_idx === 49 && @goto x49
            wheel_idx === 50 && @goto x50
            wheel_idx === 51 && @goto x51
            wheel_idx === 52 && @goto x52
            wheel_idx === 53 && @goto x53
            wheel_idx === 54 && @goto x54
            wheel_idx === 55 && @goto x55
            wheel_idx === 56 && @goto x56
            wheel_idx === 57 && @goto x57
            wheel_idx === 58 && @goto x58
            wheel_idx === 59 && @goto x59
            wheel_idx === 60 && @goto x60
            wheel_idx === 61 && @goto x61
            wheel_idx === 62 && @goto x62
            wheel_idx === 63 && @goto x63
            wheel_idx === 64 && @goto x64

            # prime_mod === 1
            while true
                @label x1
                while true
                    byte_idx > unrolled_max && break
                    xs[byte_idx + increment *  0 + 0] &= bit_1
                    xs[byte_idx + increment *  6 + 0] &= bit_2
                    xs[byte_idx + increment * 10 + 0] &= bit_3
                    xs[byte_idx + increment * 12 + 0] &= bit_4
                    xs[byte_idx + increment * 16 + 0] &= bit_5
                    xs[byte_idx + increment * 18 + 0] &= bit_6
                    xs[byte_idx + increment * 22 + 0] &= bit_7
                    xs[byte_idx + increment * 28 + 0] &= bit_8
                    byte_idx += increment * 30 + 1
                end
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 1)
                    @goto out
                end
                xs[byte_idx] &= bit_1
                byte_idx += increment * 6 + 0

                @label x2
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 2)
                    @goto out
                end
                xs[byte_idx] &= bit_2
                byte_idx += increment * 4 + 0

                @label x3
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 3)
                    @goto out
                end
                xs[byte_idx] &= bit_3
                byte_idx += increment * 2 + 0

                @label x4
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 4)
                    @goto out
                end
                xs[byte_idx] &= bit_4
                byte_idx += increment * 4 + 0

                @label x5
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 5)
                    @goto out
                end
                xs[byte_idx] &= bit_5
                byte_idx += increment * 2 + 0

                @label x6
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 6)
                    @goto out
                end
                xs[byte_idx] &= bit_6
                byte_idx += increment * 4 + 0

                @label x7
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 7)
                    @goto out
                end
                xs[byte_idx] &= bit_7
                byte_idx += increment * 6 + 0

                @label x8
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 8)
                    @goto out
                end
                xs[byte_idx] &= bit_8
                byte_idx += increment * 2 + 1
            end

            # 7
            while true
                @label x9
                while true
                    byte_idx > unrolled_max && break
                    xs[byte_idx + increment *  0 + 0] &= bit_2
                    xs[byte_idx + increment *  6 + 1] &= bit_6
                    xs[byte_idx + increment * 10 + 2] &= bit_5
                    xs[byte_idx + increment * 12 + 3] &= bit_1
                    xs[byte_idx + increment * 16 + 3] &= bit_8
                    xs[byte_idx + increment * 18 + 4] &= bit_4
                    xs[byte_idx + increment * 22 + 5] &= bit_3
                    xs[byte_idx + increment * 28 + 6] &= bit_7
                    byte_idx += increment * 30 + 7
                end
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 9)
                    @goto out
                end
                xs[byte_idx] &= bit_2
                byte_idx += increment * 6 + 1

                @label x10
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 10)
                    @goto out
                end
                xs[byte_idx] &= bit_6
                byte_idx += increment * 4 + 1

                @label x11
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 11)
                    @goto out
                end
                xs[byte_idx] &= bit_5
                byte_idx += increment * 2 + 1

                @label x12
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 12)
                    @goto out
                end
                xs[byte_idx] &= bit_1
                byte_idx += increment * 4 + 0

                @label x13
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 13)
                    @goto out
                end
                xs[byte_idx] &= bit_8
                byte_idx += increment * 2 + 1

                @label x14
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 14)
                    @goto out
                end
                xs[byte_idx] &= bit_4
                byte_idx += increment * 4 + 1

                @label x15
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 15)
                    @goto out
                end
                xs[byte_idx] &= bit_3
                byte_idx += increment * 6 + 1

                @label x16
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 16)
                    @goto out
                end
                xs[byte_idx] &= bit_7
                byte_idx += increment * 2 + 1
            end

            # 11
            while true
                @label x17
                while true
                    byte_idx > unrolled_max && break
                    xs[byte_idx + increment *  0 +  0] &= bit_3
                    xs[byte_idx + increment *  6 +  2] &= bit_5
                    xs[byte_idx + increment * 10 +  4] &= bit_1
                    xs[byte_idx + increment * 12 +  4] &= bit_7
                    xs[byte_idx + increment * 16 +  6] &= bit_2
                    xs[byte_idx + increment * 18 +  6] &= bit_8
                    xs[byte_idx + increment * 22 +  8] &= bit_4
                    xs[byte_idx + increment * 28 + 10] &= bit_6
                    byte_idx += increment * 30 + 11
                end
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 17)
                    @goto out
                end
                xs[byte_idx] &= bit_3
                byte_idx += increment * 6 + 2

                @label x18
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 18)
                    @goto out
                end
                xs[byte_idx] &= bit_5
                byte_idx += increment * 4 + 2

                @label x19
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 19)
                    @goto out
                end
                xs[byte_idx] &= bit_1
                byte_idx += increment * 2 + 0

                @label x20
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 20)
                    @goto out
                end
                xs[byte_idx] &= bit_7
                byte_idx += increment * 4 + 2

                @label x21
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 21)
                    @goto out
                end
                xs[byte_idx] &= bit_2
                byte_idx += increment * 2 + 0

                @label x22
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 22)
                    @goto out
                end
                xs[byte_idx] &= bit_8
                byte_idx += increment * 4 + 2

                @label x23
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 23)
                    @goto out
                end
                xs[byte_idx] &= bit_4
                byte_idx += increment * 6 + 2

                @label x24
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 24)
                    @goto out
                end
                xs[byte_idx] &= bit_6
                byte_idx += increment * 2 + 1
            end
        
            # 13
            while true
                @label x25
                while true
                    byte_idx > unrolled_max && break
                    xs[byte_idx + increment *  0 +  0] &= bit_4
                    xs[byte_idx + increment *  6 +  3] &= bit_1
                    xs[byte_idx + increment * 10 +  4] &= bit_7
                    xs[byte_idx + increment * 12 +  5] &= bit_6
                    xs[byte_idx + increment * 16 +  7] &= bit_3
                    xs[byte_idx + increment * 18 +  8] &= bit_2
                    xs[byte_idx + increment * 22 +  9] &= bit_8
                    xs[byte_idx + increment * 28 + 12] &= bit_5
                    byte_idx += increment * 30 + 13
                end
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 25)
                    @goto out
                end
                xs[byte_idx] &= bit_4
                byte_idx += increment * 6 + 3

                @label x26
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 26)
                    @goto out
                end
                xs[byte_idx] &= bit_1
                byte_idx += increment * 4 + 1

                @label x27
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 27)
                    @goto out
                end
                xs[byte_idx] &= bit_7
                byte_idx += increment * 2 + 1

                @label x28
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 28)
                    @goto out
                end
                xs[byte_idx] &= bit_6
                byte_idx += increment * 4 + 2

                @label x29
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 29)
                    @goto out
                end
                xs[byte_idx] &= bit_3
                byte_idx += increment * 2 + 1

                @label x30
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 30)
                    @goto out
                end
                xs[byte_idx] &= bit_2
                byte_idx += increment * 4 + 1

                @label x31
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 31)
                    @goto out
                end
                xs[byte_idx] &= bit_8
                byte_idx += increment * 6 + 3

                @label x32
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 32)
                    @goto out
                end
                xs[byte_idx] &= bit_5
                byte_idx += increment * 2 + 1
            end

            # 17
            while true
                @label x33
                while true
                    byte_idx > unrolled_max && break
                    xs[byte_idx + increment *  0 +  0] &= bit_5
                    xs[byte_idx + increment *  6 +  3] &= bit_8
                    xs[byte_idx + increment * 10 +  6] &= bit_2
                    xs[byte_idx + increment * 12 +  7] &= bit_3
                    xs[byte_idx + increment * 16 +  9] &= bit_6
                    xs[byte_idx + increment * 18 + 10] &= bit_7
                    xs[byte_idx + increment * 22 + 13] &= bit_1
                    xs[byte_idx + increment * 28 + 16] &= bit_4
                    byte_idx += increment * 30 + 17
                end
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 33)
                    @goto out
                end
                xs[byte_idx] &= bit_5
                byte_idx += increment * 6 + 3

                @label x34
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 34)
                    @goto out
                end
                xs[byte_idx] &= bit_8
                byte_idx += increment * 4 + 3

                @label x35
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 35)
                    @goto out
                end
                xs[byte_idx] &= bit_2
                byte_idx += increment * 2 + 1

                @label x36
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 36)
                    @goto out
                end
                xs[byte_idx] &= bit_3
                byte_idx += increment * 4 + 2

                @label x37
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 37)
                    @goto out
                end
                xs[byte_idx] &= bit_6
                byte_idx += increment * 2 + 1

                @label x38
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 38)
                    @goto out
                end
                xs[byte_idx] &= bit_7
                byte_idx += increment * 4 + 3

                @label x39
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 39)
                    @goto out
                end
                xs[byte_idx] &= bit_1
                byte_idx += increment * 6 + 3

                @label x40
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 40)
                    @goto out
                end
                xs[byte_idx] &= bit_4
                byte_idx += increment * 2 + 1
            end

            # 19
            while true
                @label x41
                while true
                    byte_idx > unrolled_max && break
                    xs[byte_idx + increment *  0 +  0] &= bit_6
                    xs[byte_idx + increment *  6 +  4] &= bit_4
                    xs[byte_idx + increment * 10 +  6] &= bit_8
                    xs[byte_idx + increment * 12 +  8] &= bit_2
                    xs[byte_idx + increment * 16 + 10] &= bit_7
                    xs[byte_idx + increment * 18 + 12] &= bit_1
                    xs[byte_idx + increment * 22 + 14] &= bit_5
                    xs[byte_idx + increment * 28 + 18] &= bit_3
                    byte_idx += increment * 30 + 19
                end
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 41)
                    @goto out
                end
                xs[byte_idx] &= bit_6
                byte_idx += increment * 6 + 4

                @label x42
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 42)
                    @goto out
                end
                xs[byte_idx] &= bit_4
                byte_idx += increment * 4 + 2

                @label x43
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 43)
                    @goto out
                end
                xs[byte_idx] &= bit_8
                byte_idx += increment * 2 + 2

                @label x44
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 44)
                    @goto out
                end
                xs[byte_idx] &= bit_2
                byte_idx += increment * 4 + 2

                @label x45
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 45)
                    @goto out
                end
                xs[byte_idx] &= bit_7
                byte_idx += increment * 2 + 2

                @label x46
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 46)
                    @goto out
                end
                xs[byte_idx] &= bit_1
                byte_idx += increment * 4 + 2

                @label x47
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 47)
                    @goto out
                end
                xs[byte_idx] &= bit_5
                byte_idx += increment * 6 + 4

                @label x48
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 48)
                    @goto out
                end
                xs[byte_idx] &= bit_3
                byte_idx += increment * 2 + 1
            end

            # 23
            while true
                @label x49
                while true
                    byte_idx > unrolled_max && break
                    xs[byte_idx + increment *  0 +  0] &= bit_7
                    xs[byte_idx + increment *  6 +  5] &= bit_3
                    xs[byte_idx + increment * 10 +  8] &= bit_4
                    xs[byte_idx + increment * 12 +  9] &= bit_8
                    xs[byte_idx + increment * 16 + 13] &= bit_1
                    xs[byte_idx + increment * 18 + 14] &= bit_5
                    xs[byte_idx + increment * 22 + 17] &= bit_6
                    xs[byte_idx + increment * 28 + 22] &= bit_2
                    byte_idx += increment * 30 + 23
                end
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 49)
                    @goto out
                end
                xs[byte_idx] &= bit_7
                byte_idx += increment * 6 + 5

                @label x50
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 50)
                    @goto out
                end
                xs[byte_idx] &= bit_3
                byte_idx += increment * 4 + 3

                @label x51
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 51)
                    @goto out
                end
                xs[byte_idx] &= bit_4
                byte_idx += increment * 2 + 1

                @label x52
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 52)
                    @goto out
                end
                xs[byte_idx] &= bit_8
                byte_idx += increment * 4 + 4

                @label x53
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 53)
                    @goto out
                end
                xs[byte_idx] &= bit_1
                byte_idx += increment * 2 + 1

                @label x54
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 54)
                    @goto out
                end
                xs[byte_idx] &= bit_5
                byte_idx += increment * 4 + 3

                @label x55
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 55)
                    @goto out
                end
                xs[byte_idx] &= bit_6
                byte_idx += increment * 6 + 5

                @label x56
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 56)
                    @goto out
                end
                xs[byte_idx] &= bit_2
                byte_idx += increment * 2 + 1
            end

            # 29
            while true
                @label x57
                while true
                    byte_idx > unrolled_max && break
                    xs[byte_idx + increment *  0 +  0] &= bit_8
                    xs[byte_idx + increment *  6 +  6] &= bit_7
                    xs[byte_idx + increment * 10 + 10] &= bit_6
                    xs[byte_idx + increment * 12 + 12] &= bit_5
                    xs[byte_idx + increment * 16 + 16] &= bit_4
                    xs[byte_idx + increment * 18 + 18] &= bit_3
                    xs[byte_idx + increment * 22 + 22] &= bit_2
                    xs[byte_idx + increment * 28 + 28] &= bit_1
                    byte_idx += increment * 30 + 29
                end
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 57)
                    @goto out
                end
                xs[byte_idx] &= bit_8
                byte_idx += increment * 6 + 6

                @label x58
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 58)
                    @goto out
                end
                xs[byte_idx] &= bit_7
                byte_idx += increment * 4 + 4

                @label x59
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 59)
                    @goto out
                end
                xs[byte_idx] &= bit_6
                byte_idx += increment * 2 + 2

                @label x60
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 60)
                    @goto out
                end
                xs[byte_idx] &= bit_5
                byte_idx += increment * 4 + 4

                @label x61
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 61)
                    @goto out
                end
                xs[byte_idx] &= bit_4
                byte_idx += increment * 2 + 2

                @label x62
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 62)
                    @goto out
                end
                xs[byte_idx] &= bit_3
                byte_idx += increment * 4 + 4

                @label x63
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 63)
                    @goto out
                end
                xs[byte_idx] &= bit_2
                byte_idx += increment * 6 + 6

                @label x64
                if byte_idx > n_bytes
                    advance!(p, segment_index_start + byte_idx - 1, 64)
                    @goto out
                end
                xs[byte_idx] &= bit_1
                byte_idx += increment * 2 + 1
            end

            @label out
        end

        for i = 1 : n_bytes
            count += count_ones(xs[i])
        end

        segment_index_start += segment_length
    end

    return count
end