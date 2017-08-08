.PHONY: all clean
CFLAGS=-g -O0 -Wall -Werror
BINS=\
 demo1.bin \
 demo2.bin \
 demo3.bin \
 demo4.bin \
 demo5.bin

all: $(BINS)

# uvm
uvm: uvm.o
	$(CC) -o uvm uvm.o

# uasm stage 1
uasm1: uasm1.lex.o
	$(CC) -o uasm1 uasm1.lex.o -ll -lm

uasm1.lex.o: uasm1.lex.c uvm.h

uasm1.lex.c: uasm1.l
	$(LEX) -o uasm1.lex.c uasm1.l

# uasm stage 2
uasm2: uasm2.lex.o
	$(CC) -o uasm2 uasm2.lex.o -ll -lm

uasm2.lex.o: uasm2.lex.c uvm.h

uasm2.lex.c: uasm2.l
	$(LEX) -o uasm2.lex.c uasm2.l

# assemble and run demos
%.bin: %.asm uasm1 uasm2 uvm
	@echo ==== $< ====
	./uasm $< $@
	./uvm $@
	@echo ==================

clean:
	rm -f *.o core
	rm -f uasm1 uasm2 uasm?.lex.c
	rm -f uvm
	rm -f *.bin *.labels
