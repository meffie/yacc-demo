#!/bin/bash
set -e

src=demo$1.src
if [ -z "$src" -o ! -f "$src" ]; then
    echo "usage: demo <number>" >&2
    exit 1
fi
asm="$(basename $src ".src").asm"
bin="$(basename $src ".src").bin"

set -x
./blue $src $asm
uasm $asm $bin
uvm $bin
