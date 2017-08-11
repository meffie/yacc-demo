

CFLAGS=-g -O0

calc: symtab.o y.tab.o lex.yy.o
	$(CC) -o calc symtab.o y.tab.o lex.yy.o -ll -lm

lex.yy.o: lex.yy.c y.tab.h

y.tab.c y.tab.h: calc.y
	$(YACC) -d calc.y

lex.yy.c: calc.l
	$(LEX) calc.l

clean:
	rm -f calc *.o y.tab.c y.tab.h lex.yy.c demo.txt

demo: calc
	sh demo.sh
