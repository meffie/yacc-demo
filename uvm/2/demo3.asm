#
# hello world demo
#
    push 0    # nul
    push 10   # <newline>
    push 100  # 'd'
    push 108  # 'l'
    push 114  # 'r'
    push 111  # 'o'
    push 119  # 'w'
    push 32   # ' '
    push 111  # 'o'
    push 108  # 'l'
    push 108  # 'l'
    push 101  # 'e'
    push 104  # 'h'

loop:
    dup             # dup for branch check
    write           # write char (pops an element)
    branch $loop    # continue until nul (pops an element)
