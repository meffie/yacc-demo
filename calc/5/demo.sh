#!/bin/sh

cat > demo.txt << EOF
height = 3.0
depth = 4.0
sqrt(height*height + depth*depth)
EOF

echo ""; echo "input:"
cat demo.txt
echo ""; echo "output:"
./calc < demo.txt
