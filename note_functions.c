#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "note_functions.h"

extern int debug;
extern int octave12ET, baseIndex12ET, origin;

static const int adjust8ve [7][7] =  {
       // C0, D1, E2, F3, G4, A5, B6
        {  0,  0,  0,  0, -1, -1, -1}, // C 0
        {  0,  0,  0,  0,  0, -1, -1}, // D 1
        {  0,  0,  0,  0,  0,  0, -1}, // E 2
        {  0,  0,  0,  0,  0,  0,  0}, // F 3
        {  0,  0,  0,  0,  0,  0,  0}, // G 4
        {  1,  1,  0,  0,  0,  0,  0}, // A 5
        {  1,  1,  1,  0,  0,  0,  0} // B 6
};

const int relativeAdjustOctave(const int last, const int current)
{
        // Don't adjust octave if last note is undefined.
        return last < 0 ? 0 : adjust8ve[last][current];
}


const int lookup19ET[] = 
 /* Cbb Cb  C C# Cx Dbb Db  D D# Dx Ebb Eb E E# Ex Fbb Fb F F#  Fx */
  { -2, -1, 0, 1, 2,  1, 2, 3, 4, 5, 4, 5, 6, 7, 8, 6, 7, 8, 9, 10,
 /*Gbb Gb   G  G#  Gx Abb  Ab   A  A#  Ax Bbb  Bb   B  B#  Bx */
    9, 10, 11, 12, 13, 12, 13, 14, 15, 16, 15, 16, 17, 18, 19};

const int lookup12ET[] =
 /* Cb  C C# Db  D  D# Eb E  E# Fb F  F#  Gb   G  G#  Ab   A  A#  Bb   B  B# */
  { -2, 0, 1, 2, 3, 4, 5, 6, 7, 6, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19};

const char *spell12ET[] =
  { "c", "cis", "d", "ees", "e", "f", "fis", "g", "aes", "a", "bes", "b" };


int convert12ETto19ET(int note, int acc, int oct)
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

char *str12ET(int notenum)
{
        /* Given a 19ET note number (e.g. from the above subroutine),
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
