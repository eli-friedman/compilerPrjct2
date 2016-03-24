parser:   y.tab.c lex.yy.c table.c proj2.c
	gcc  -g -o parser y.tab.c proj2.c -lfl
y.tab.c:  grammar.y
	yacc -v grammar.y
lex.yy.c: lex.l 
	flex lex.l
