#
# Demonstrate use of local variables and array elements using peek, poke, and
# ipeek (indirect peek).
#
# Finds the maximum element of array A.
#
# locals:
#   0: current max
#   1: index, 0 to n
#   2: length of A
#   3: A[0], base of A
#   ...
#   3+n-1: A[n-1], last element of a
#

# initialize locals
    push 0     # max
    push 0     # i
    push 4     # len(A)
    push 1007  # A[0]
    push 1009  # A[1]
    push 1003  # A[2]
    push 1004  # A[3]

# for each A[i] in A:
#    set max if A[i] > max
loop:
    peek 1   # i
    ipeek 3  # A[i]
    peek 0   # max
    gt
    branch $setmax

nexti:
    peek 1   # i
    push 1   #
    add      # i+1
    dup      #
    poke 1   # let i := i+i
    peek 2   #
    lt       # i < n ?
    branch $loop
    jump $done

setmax:
    peek 1   # i
    ipeek 3  # A[i]
    poke 0
    jump $nexti

done:
    peek 0
    print   # max
