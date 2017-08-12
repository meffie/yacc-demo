CFLAGS=-g -O0 -Wall -Werror

yblog: lex.yy.o debug.o
	$(CC) -o yblog lex.yy.o debug.o -ll -lm

debug.o: debug.c
lex.yy.o: lex.yy.c

lex.yy.c: yblog.l
	$(LEX) yblog.l

clean:
	rm -f yblog *.o lex.yy.c

demo: yblog
	./yblog < demo.txt
