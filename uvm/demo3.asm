#
# Call demo
#

  push $done1
  push 1000
  push 2000
  jump $mysub
done1:

  push $done2
  push 3000
  push 4000
  jump $mysub
done2:

  halt

mysub:
  push 200
  sub
  add
  print
  return

#
# bytecode:
# 010000001401000003e801000007d0130000002901000000280100000bb8
# 0100000fa013000000291601000000c806051915
#
