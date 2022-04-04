# Simple makefile for Scordify19

LEXLIB := fl
PROGNAME := scordify19

scordify19:	lex.yy.o
	$(CC) -o $(PROGNAME) $< -l$(LEXLIB)

lex.yy.c:	scordify19.lex
	$(LEX) $<
