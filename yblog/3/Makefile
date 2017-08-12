CFLAGS=-g -O0 -Wall -Werror

yblog: debug.o lex.yy.o y.tab.o y.tab.h
	$(CC) -o yblog debug.o lex.yy.o y.tab.o -ll -lm

y.tab.c y.tab.h: yblog.y
	$(YACC) -d yblog.y

lex.yy.c: yblog.l y.tab.h
	$(LEX) yblog.l

clean:
	rm -f yblog *.o lex.yy.c y.tab.c y.tab.h demo.html

demo: yblog
	./yblog <demo.txt >demo.html
