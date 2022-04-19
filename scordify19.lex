%{
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

#include "note_functions.h"

static int noteNum, accidentalOffset, octaveOffset; /* indexes lookup table */
static int lastNote = -1;  /* In relative mode, the octave might have to change for big steps */
static int octave;    /* octave number from score ("'" counts +ve, "," -ve) */
static int relativeMode = 0;  /* assume we're not in relative mode at start */
extern int debug;     /* Global debug flag */
extern int octave12ET;                    /* Octave of the 12ET origin note */
extern int origin;              /* 19-ET note number of the keyboard origin */
extern int baseIndex12ET;     /* Basis for lookups into 12ET spelling array */

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
  
"\\"[a-zA-Z]+ {
	/* Don't change commands */
	ECHO;
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
      // NOTE: lilypond behaviour is to set the octave from the next score note
      // but for now we'l just set it to 1.
      octaveOffset = octave = 1;
	  BEGIN(INITIAL);
    }
}

%%

