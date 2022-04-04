\new StaffGroup
<<

    \new Staff \relative c, {

	    \override Score.MetronomeMark #'padding = #'4.0
        \tempo 4=120

	    \override Score.BarNumber #'break-visibility = #end-of-line-invisible
		\override Score.BarNumber #'extra-offset = #'(1.5 . 1.7)

        \set Staff.instrument = \markup {
          \center-column { "Clarinet"
                         { "in B" \smaller \flat }
          }
        }
        \set Staff.instr = "Cl"
        \time 3/2
        \clef treble
		g2( d' a'

		\time 3/8
		c4.

		\time 2/4
		des4 ees
		f2
		e4 b

        \time 3/8
		cis4.

		\time 9/8
		d4.) r d

		%%% Bar 8
		ees4.( bis ais
		g) r4. g(
		
		\time 3/8
		bes

		\time 3/4
		aes2 ges4
		c2.)

		%%% Bar 13
		\time 3/8
		g4.(

		\time 4/4
		fis2 gis
		a) d(
		dis eis

		\time 3/8
		a4.

		\time 6/4
		g1.)

    }

    \new Staff \relative c' {
	    \set Staff.instrument = "Continuo"
        \set Staff.instr = "Cont"
	    \clef treble

        <f g bes c>1.~

        <f g bes c>4.

        \once\override Tie #'control-points = 
        	     #'((1.6 . 0) (4 . 1.0) (5 . -2.8) (7.9 . -1))
		<f aes>2~
		<aes bes>
		<f a>~
                	\once\override Tie #'control-points = 
                  #'((1.0 . -2.0) (4.2 . -3.8) (5 . 1.5) (8.8 . -1))
		<f a>4.~
		\noBreak
		<ees f>2.~ <ees f>4.~

		%%% Bar 8
		<des ees>2.~ <des ees>4.
		<ees f>2.~ <ees f>4.~
		<ees f>
		\tieUp
		<ges bes>2.~
		\tieNeutral
		<f bes>~

		%%% Bar 13
		<bes f>4.
		<a c>1
                \once\override Tie #'control-points = 
                  #'((1.6 . -0.5) (4 . 0.5) (5 . -3.3) (8.9 . -1.5))
		<f g>~
		<g a>~
		<g a>4.~
		<f g bes c>1.
    }
>>
