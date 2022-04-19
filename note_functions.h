#ifndef _NOTE_FUNCTIONS_H_
#define _NOTE_FUNCTIONS_H_

extern const int lookup19ET[];
extern const int lookup12ET[];
extern const char *spell12ET[];
int relativeAdjustOctave(int last, int current);
int convert12ETto19ET(int note, int acc, int oct);
char *str12ET(int notenum);

#endif
