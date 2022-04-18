# Simple makefile for Scordify19

LEXLIB := fl
PROGNAME := scordify19
SRCS := lex.yy.c relative.c
OBJS := $(SRCS:%.c=%.o)
DEPFILES := $(CSRCS:%.cxx=$(DEPDIR)/%.d)

DEPDIR := .deps
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.d
CC := gcc
COMPILE.c = $(CC) $(DEPFLAGS) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c

$(PROGNAME) :: $(OBJS)
	$(LINK.c) -o $(PROGNAME) $^ -l$(LEXLIB)

lex.yy.c : scordify19.lex
	$(LEX) $<

%.o :: %.c $(DEPDIR)/%.d
	$(COMPILE.c) $(OUTPUT_OPTION) $<


.PHONY: tests
tests: $(PROGNAME)
	( cd tests ; ./test.sh 2>&1 | tee -a tests.log )


.PHONY: clean
clean:
	rm -f  *.o $(PROGNAME) -r $(DEPDIR)

$(DEPDIR):
	mkdir -p $@ 

$(DEPFILES):

*.c *.o : | $(DEPDIR)

include $(wildcard $(DEPFILES))
