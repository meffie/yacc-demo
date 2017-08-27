CFLAGS=-g -O0 -Wall -Werror

blue: y.tab.o lex.yy.o compile.o debug.o
	$(CC) -o blue compile.o debug.o y.tab.o lex.yy.o -ll -lm

compile.o: compile.c compile.h y.tab.h
debug.o: debug.h
lex.yy.o: lex.yy.c y.tab.h

y.tab.c y.tab.h: parser.y compile.h
	$(YACC) --verbose -d parser.y

lex.yy.c: scanner.l
	$(LEX) scanner.l

clean:
	rm -f blue *.o y.tab.c y.tab.h lex.yy.c y.output *.asm *.bin

