#
# Loop demo; countdown from 10 to 1.
#
    push 10
loop:
    dup
    print
    push 1
    sub
    dup
    branch $loop
