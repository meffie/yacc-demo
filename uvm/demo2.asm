#
# Loop demo
#
start:
  push 10
loop:
  push 1
  sub
  dup
  print
  branch loop

#
# bytecode:
# 010000000a01000000010604191400000005
#
