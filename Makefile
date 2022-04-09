# Simple makefile for Scordify19

LEXLIB := fl
PROGNAME := scordify19

scordify19:	lex.yy.o
	$(CC) -o $(PROGNAME) $< -l$(LEXLIB)

lex.yy.c:	scordify19.lex
	$(LEX) $<

.PHONY: tests
tests:	$(PROGNAME)
	( cd tests ; ./test.sh | tee tests.log )
