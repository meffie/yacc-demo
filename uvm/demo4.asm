#
# Demo hello world
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
  write
  branch $loop

#
# bytecode:
# 0100000000010000000a0100000064010000006c0100000072010000006f
# 01000000770100000020010000006f010000006c010000006c0100000065
# 0100000068181400000041
#
