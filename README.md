# scordify19 #
## Automatic convertion of Lilypoind scores for 19EDO performance ##
Scordify19 is a program to transcribe a score composed in 19-EDO and engraved
in Lilypond so that it can performed on a _scordatura keyboard_
(which is to say, one in which the 19 tones of the octave are mapped
onto a conventional keyboard by retuning it).

### Building ###
Requres flex and a compiler.
Type **make**. That is all.

### Testing ###
Running unit tests requires *shunit2* to be installed.

**make tests** runs the unit tests.

## Limitations ##
Clearly it would have been better to write a scheme function and have
lilypond do all the work, but I just don't understand the internals of
Lilypond enough to do that. This program does its best to convert
files to scordatura notation, but there are the following notable
limitations:

 * `\relative` must be followed by a `c` of some sort. This sets
   the octave for the following note, and relative processing continues
   from there. You can't turn it off once it's started.
 * Chords in lilypond have a relative note given by the bottom note.
   **scordify19** dumbly spits out the `<` and `>` characters and
   continues processing. For the scores it was written for, this didn't
   matter much because the notes could be re-processed from the following
   lines after reissuing a correxting `\relative` at the console.
   
This last point is probably the biggest TODO to make the program more generally
useful, but it may well be easier for someone fluent in scheme
to do the right thing and rewrite it completely. Still, what's here is here
in the hope it'll be useful for someone.
