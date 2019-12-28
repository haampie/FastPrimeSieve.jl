pcountprimes(to; segment_length = 1024 * 32, threads = Threads.nthreads()) = pcountprimes(1, to, segment_length = segment_length, threads = threads)

"""
Get segment `i` when dividing `from:to` into `n` pieces
"""
function segment(from, to, i, n)
    div, rem = divrem(length(from:to), n)
    start = from + (div + 1) * min(i - 1, rem) + div * max(0, i - 1 - rem)
    stop = from + (div + 1) * min(i, rem) + div * max(0, i - rem) - 1
    start, stop
end

function pcountprimes(from, to; segment_length = 1024 * 32, threads = Threads.nthreads())

    from = max(2, from)

    counts = zeros(Int, threads)

    Threads.@sync for i in Base.OneTo(threads)
        Threads.@spawn begin
            start, stop = segment(from, to, i, threads)
            counts[i] = countprimes(start, stop, segment_length = segment_length)
        end
    end
    
    return sum(counts)
end