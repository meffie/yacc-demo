.PHONY: all clean demo1 demo2 demo3 demo4
CFLAGS=-g -O0 -Wall

all: demo1 demo2 demo3 demo4

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

# demo1
demo1: demo1.bin uvm
	@echo ==== demo1 ====
	./uvm demo1.bin
	@echo ===============

demo1.bin: demo1.asm uasm1 uasm2
	./uasm demo1.asm demo1.bin

# demo2
demo2: demo2.bin uvm
	@echo ==== demo2 ====
	./uvm demo2.bin
	@echo ===============

demo2.bin: demo2.asm uasm1 uasm2
	./uasm demo2.asm demo2.bin

# demo3
demo3: demo3.bin uvm
	@echo ==== demo3 ====
	./uvm demo3.bin
	@echo ===============

demo3.bin: demo3.asm uasm1 uasm2
	./uasm demo3.asm demo3.bin

# demo4
demo4: demo4.bin uvm
	@echo ==== demo4 ====
	./uvm demo4.bin
	@echo ===============

demo4.bin: demo4.asm uasm1 uasm2
	./uasm demo4.asm demo4.bin

clean:
	rm -f *.o core
	rm -f uasm1 uasm2 uasm?.lex.c
	rm -f uvm
	rm -f *.bin *.labels
