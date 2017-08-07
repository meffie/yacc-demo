#
# Demonstrate subroutines with elementary stack frames.
#

    #ton
    mark       # mark new frame
    push 100   # call parameters
    push 200
    call $mysub1  # invoke call
    nop
    unmark
    halt

mysub1:
    add
    mark    # mark new frame
    peek 0  # set call parameter from local
    push 2  # set call parameter with literal
    call $mysub2
    poke 0  # save return to local
    unmark  # teardown frame
    return

mysub2:
    mul
    return
