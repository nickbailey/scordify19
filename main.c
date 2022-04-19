#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>

#include "note_functions.h"

int debug;     /* Global debug flag */
int octave12ET;                    /* Octave of the 12ET origin note */
int origin;              /* 19-ET note number of the keyboard origin */
int baseIndex12ET;     /* Basis for lookups into 12ET spelling array */

int yylex(void);

int main(int argc, char *argv[])
{
  int note, acc;
  char *c;
  int opt;

  while ((opt = getopt(argc, argv, "d")) != -1)
	switch (opt) {
	case 'd':
	  debug = 1;
	  break;
	case '?':
	  fprintf(stderr, "Unknown option \"%c\"\n", optopt);
	  break;
	}
	
  if (optind != argc-1) {
	fprintf(stderr, "Usage: %s [-d] <origin>\n\te.g. %s \"fis''\"\n",
			argv[0], argv[0]);
	exit(1);
  }

  /* Validate the origin note */
  note = tolower(argv[optind][0]);
  if (note < 'a' || note > 'g') {
	fprintf(stderr, "%s: Fatal: origin note must be between A and G.\n)",
			argv[0]);
	exit(2);
  }
  note -= 'c';
  if (note < 0) note += 7;
  argv[optind]++;

  /* Check for an accidental (is or es) */
  if (strncmp(argv[optind], "is", 2) == 0) {
	acc = 1;
	argv[1] += 2;
  } else if (strncmp(argv[optind], "es", 2) == 0) {
	acc = -1;
	argv[optind] += 2;
  } else acc = 0;

  /* Read the octave mark of the origin note */
  octave12ET = 0;
  for (c = argv[optind]; *c; ++c) {
	if (*c == '\'') ++octave12ET;
	else if (*c == ',') --octave12ET;
	else {
	  fprintf(stderr,
			  "%s: Fatal: origin octave qualifier must contain"
			  " only \"'\" and \",\" characters.\n", argv[0]);
	  exit(2);
	}
  }

  /* Convert the origin into a note number */
  origin = lookup12ET[3*note+acc+1] + 19*octave12ET;

  /* Store the base index of the origin note in the 12ET spelling array */
  baseIndex12ET = note*2 + acc;
  if (baseIndex12ET < 0) baseIndex12ET = 11;

  yylex();
}
