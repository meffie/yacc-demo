.PHONY: all clean
CFLAGS=-g -O0 -Wall -Werror

all: uvm uasm
demo: demo1.bin demo2.bin demo3.bin demo4.bin demo5.bin

# uvm
uvm: uvm.o
	$(CC) -o uvm uvm.o

# uasm
uasm: lex.yy.o
	$(CC) -o uasm lex.yy.o -ll -lm

lex.yy.o: lex.yy.c

lex.yy.c: uasm.l
	$(LEX) uasm.l

# assemble and run demos
%.bin: %.asm uasm uvm
	@echo ==== $< ====
	./uasm $< $@
	./uvm $@
	@echo ==================

clean:
	rm -f *.o *.bin core uvm uasm lex.yy.c
