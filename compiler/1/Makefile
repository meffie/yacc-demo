.PHONY: demo clean
CFLAGS=-g -O0 -Wall -Werror

blue: y.tab.o lex.yy.o
	$(CC) -o blue y.tab.o lex.yy.o -ll -lm

lex.yy.o: lex.yy.c y.tab.h

y.tab.c y.tab.h: parser.y
	$(YACC) --verbose -d parser.y

lex.yy.c: scanner.l
	$(LEX) scanner.l

clean:
	rm -f blue *.o y.tab.c y.tab.h lex.yy.c y.output

demo: blue
	./blue demo0.src
