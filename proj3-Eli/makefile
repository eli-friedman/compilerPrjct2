LEX=lex
YACC=yacc
CC=gcc
CC_FLAG=-ll

build: lex.yy.o y.tab.o proj2.o proj3.o
	$(CC) -o parser lex.yy.o y.tab.o proj2.o proj3.o

debug:	lex.yy.o d-y.tab.o proj2.o
	$(CC) -o parser lex.yy.o y.tab.o proj2.o
	
lex.yy.o:	lex
	$(CC) -c lex.yy.c $(CC_FLAG)

y.tab.o:	yacc
	$(CC) -c y.tab.c 	


d-y.tab.o:	yacc-debug
	$(CC) -c y.tab.c 


proj2.o: proj2.c
	$(CC) -c proj2.c

proj3.o: proj3.c
	$(CC) -c proj3.c

yacc: mJava.y
	$(YACC)  -d -v  $< 

yacc-debug: mJava.y
	$(YACC)  -d -v -t $<

lex: mJava.l yacc
	$(LEX) $< 




clean:	
	rm  parser lex.yy.c y.output y.tab.h y.tab.c  y.tab.o  lex.yy.o proj2.o proj3.o
