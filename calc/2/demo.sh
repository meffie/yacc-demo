#!/bin/sh

cat > demo.txt << EOF
1 + 2 * 3
EOF

echo ""; echo "input:"
cat demo.txt
echo ""; echo "output:"
./calc < demo.txt
