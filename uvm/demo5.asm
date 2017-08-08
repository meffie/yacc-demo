#
# Greatest common divisor using Euclid's method.
#
#   gdc(a, b):
#       if b == 0:
#           return a
#       else:
#           return gcd(b, a % b)
#

main:
    push 0        # make a slot for the result
    mark          # setup parameters
    push 21       # 0:a
    push 30       # 1:b
    call $gcd     # gcd(21, 30)
    poke 0        # save result
    unmark        # unwind frame
    print         # print result
    halt          # all done

gcd:
    peek 1        # b
    branch $again # b != 0 ?
    pop           # yes: toss b
    return        # a
again:
    mark          # setup parameters
    peek 1        # b
    peek 0        # a
    peek 1        # b
    mod           # a % b
    call $gcd     # gcd(b, a % b)
    poke 0        # save result (clobbers old a)
    unmark        # unwind frame
    pop           # toss b
    return        # a
