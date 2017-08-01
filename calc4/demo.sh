#!/bin/sh

cat > demo.txt << EOF
Farhenheit = 72.0
Celsius = 5.0 * (Farhenheit - 32.0) / 9.0
Farhenheit
Celsius
EOF

echo ""; echo "input:"
cat demo.txt
echo ""; echo "output:"
./calc < demo.txt
