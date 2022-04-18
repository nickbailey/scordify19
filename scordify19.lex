%{
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

#include "relative.h"

static int noteNum, accidentalOffset, octaveOffset; /* indexes lookup table */
static int lastNote = -1;  /* In relative mode, the octave might have to change for big steps */
static int octave;    /* octave number from score ("'" counts +ve, "," -ve) */
static int origin;              /* 19-ET note number of the keyboard origin */
static int baseIndex12ET;     /* Basis for lookups into 12ET spelling array */
static int octave12ET;                    /* Octave of the 12ET origin note */
static int relativeMode = 0;  /* assume we're not in relative mode at start */
int debug = 0;     /* Global debug flag */

/* Forward Declarations */
static int convert12ETto19ET(int, int, int);
static char *str12ET(int);
%}

TERMINATOR [][></_^~)(.\\[:space:]}{:]
NAME       [a-g]
ACCIDENTAL ("is"|"es"){1,2}
DURATION   [[:digit:]]*\.*
OCTAVE     (","|"'")*

%x Relative IsNote
%%

"\\relative"[ \t]+ {
    /* Change into relative mode */
	relativeMode = 1;
    BEGIN(Relative);
    /* Don't echo lilypond's relative directive: we'll be converting
	   to absolute in order to preserve sanity */
  }

{NAME}/{ACCIDENTAL}?{OCTAVE}("!"|"?")?{DURATION}?{TERMINATOR}  {
    /* Matches note, new state. */
    /* Set default accidental and octave recorded in the input file */
    accidentalOffset = 0;
    //octave = 0;

    /* Note has three possible qualifiers, #, None (natural), or b */
    lastNote = noteNum;
    noteNum = yytext[yyleng-1] - 'c'; // yyleng should always be 1
	if (noteNum < 0) noteNum += 7;
	if (relativeMode) {

	/* Depending on the step, we may have to adjust the current octave */
		int octaveAdjust = relativeAdjustOctave(lastNote, noteNum);
		octave += octaveAdjust;
		
		if (debug) {
			fprintf(stderr, "Melodic interval %c-%c: octave adjusted by %d, now %d\n",
				lastNote+'c'-7*(lastNote>4), noteNum+'c'-7*(noteNum>4), octaveAdjust, octave);
		}

	} else {
		octave = 0;
	}
	yytext[yyleng-1] = '\0';
	fputs(yytext, yyout);
    BEGIN(IsNote);
  }

%{ 
/* The IsNote state is entered when we suspect a note's been found.
   Extract and store its interesting parameters */
%}

<IsNote>{

  {ACCIDENTAL}	{
	  /* Matches accidental */
	  accidentalOffset = ( yytext[0]=='e' ?
						   -1 /* flats */ :
						   1 /* sharps */ ) * yyleng/2;
    }

  {OCTAVE}   {
	  /* Matches octave */
	  int octaveRead = yytext[0]=='\'' ? yyleng : -yyleng;
	  octave = relativeMode ? octave + octaveRead : octaveRead;
    }

  "!"|"?"    { /* Just ignore cautionary and obligatory accidentals */
	           /* All notes have mandatory accidentals in the output anyway */
    }

  .|"\n" {
	  char *scord = str12ET(convert12ETto19ET(noteNum,
											  accidentalOffset,
											  octave));
	  /* Default rule: end of note. Return to initial state */
	  if (debug)
		fprintf(stderr,
				"\n[%d] acc %d oct %d\t",
				noteNum, accidentalOffset, octave);
	  fputs(scord, yyout);
	  free(scord);
	  /* Finished with this note. Push the character back onto the input
		 stream so that the next note detected will start at the
		 appropriate character */
	  unput(yytext[0]);
      BEGIN(INITIAL);
    }
}

%{
  /* The Relative state indicates a lilypond directive of the form
	     \relative c''
	 has been found, and the \relative part has already been matched.
	 This state counts the octave marks, sets the current octave, then
	 returns to the initial state.
	 
	 Note that the octaveOffset feature isn't implemented in the output
	 engine yet, but the lexing rules are here for future improvement */
%}

<Relative>{
  c{OCTAVE}/{TERMINATOR} {
	  if (yytext[1] == '\0') /* Special case of no ' or , */
	    octaveOffset = 0;
	  else
	    octaveOffset = yytext[1]=='\'' ? yyleng-1 : 1-yyleng;

	  octave = octaveOffset;
	  noteNum = -1; // Don't do octave offset in relative mode on first note

	  if (debug) fprintf(
		stderr,
		"Relative directive sets octave to %d\n", octaveOffset
	  );

	  BEGIN(INITIAL);
    }
    
  .|\n     {
      /* If there's no note, we'll assume this \relative has no argument */
      unput(yytext[0]);
      octaveOffset = 1;
	  BEGIN(INITIAL);
    }
}

%%

static int lookup19ET[] = 
 /* Cbb Cb  C C# Cx Dbb Db  D D# Dx Ebb Eb E E# Ex Fbb Fb F F#  Fx */
  { -2, -1, 0, 1, 2,  1, 2, 3, 4, 5, 4, 5, 6, 7, 8, 6, 7, 8, 9, 10,
 /*Gbb Gb   G  G#  Gx Abb  Ab   A  A#  Ax Bbb  Bb   B  B#  Bx */
    9, 10, 11, 12, 13, 12, 13, 14, 15, 16, 15, 16, 17, 18, 19};

static int lookup12ET[] =
 /* Cb  C C# Db  D  D# Eb E  E# Fb F  F#  Gb   G  G#  Ab   A  A#  Bb   B  B# */
  { -2, 0, 1, 2, 3, 4, 5, 6, 7, 6, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19};

static char *spell12ET[] =
  { "c", "cis", "d", "ees", "e", "f", "fis", "g", "aes", "a", "bes", "b" };

/* The actual program */

static int convert12ETto19ET(int note, int acc, int oct)
{
  /* Given the 12ET note number (1=C, 2=D, ...), accidental (2=x, -2=bb)
	 and octive number (c'=1), return the 19ET note number taking the
	 equivalence origin into account */

  int absolute = lookup19ET[note*5 + acc + 2] + 19*oct;
  if (debug)
	fprintf(stderr,
			"\t(%d %d %d) converted to %d\t",
			note, acc, oct, absolute-origin);

  return absolute - origin;
}

static char *str12ET(int notenum)
{
  /* given a 19ET note number (e.g. from the above subroutine),
	 return a printable string representing the scordatura tuning
	 in lilypond format */

  int index = baseIndex12ET + notenum;
  int oct;
  char *result;

  if (index >= 0) {
	oct = octave12ET + index/12;
	index %= 12;
  } else {
	oct = octave12ET + index/12 - 1;
	index = 12 + (index%12);
	if (index == 12) {
	    index = 0;
	    oct++;
	}
  }
  if (debug)
	fprintf(stderr, "12ET spell index = %d oct adj = %d\n", index, oct);
  /* make up the 12ET string */
  result = malloc(oct>0 ? 5+oct : 5-oct);
  strcpy(result, spell12ET[index]);
  if (oct > 0)
	while (oct--)
	  strcat(result, "'");
  else
	while (oct++)
	  strcat(result, ",");

  /* Finally, add an obligatory accidental to all notes */
  strcat(result, "!");
  return result;
  
}

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
