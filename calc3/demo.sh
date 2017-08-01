#!/bin/sh

cat > demo.txt << EOF
f = 72.0
c = 5.0 * (f - 32.0) / 9.0
c
EOF

echo ""; echo "input:"
cat demo.txt
echo ""; echo "output:"
./calc < demo.txt
