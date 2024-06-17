\version "2.25.0"

\paper { #(set-paper-size "11x17") }
\include "../instrument-name-measuring-engraver.ily"

music = {
  \tempo "Tempo" s1*4 \mark \default \break s
}

\language "english"

#(define-markup-command (append-flat layout properties text) (markup?)
  (interpret-markup layout properties
    #{ \markup \concat { #text \raise #0.4 \fontsize #-3 \flat } #}))

\score {
  <<
    \new StaffGroup="Woodwinds"
    <<
      \new Staff \with {
        instrumentName ="Piccolo"
        shortInstrumentName = "Picc."
        midiInstrument = "piccolo"
      } {
        \new Voice \with {
          \consists Mark_engraver
          \consists Metronome_mark_engraver
          \consists Staff_collecting_engraver
          \override MetronomeMark.font-size = #2
        } {
          \clef "treble^8"
          \music
        }
      }

      \new Staff \with {
        instrumentName = "2 Flutes"
        shortInstrumentName = \markup { \shared-stave "Fl." \right-column { "1" "2" } }
        midiInstrument = "flute"
        \consists Merge_rests_engraver
      } {
        \music
      }

      \new Staff \with {
        instrumentName = "2 Oboes"
        shortInstrumentName = \markup { \shared-stave "Ob." \right-column { "1" "2" } }
        midiInstrument = "oboe"
        \consists Merge_rests_engraver
      } {
        \music
      }

      \new Staff \with {
        instrumentName = "English Horn"
        shortInstrumentName = "E. Hn."
        midiInstrument = "english horn"
        \consists Merge_rests_engraver
      } {
        \transposition f
        \transpose f c' {
          \music
        }
      }

      \new Staff \with {
        instrumentName = \markup { \append-flat "2 Clarinets in B" }
        shortInstrumentName = \markup {
          \shared-stave
            \column { "Cl." \append-flat "in B" }
            \right-column { "1" "2" }
        }
        midiInstrument = "clarinet"
        \consists Merge_rests_engraver
      } {
        \transposition b-flat
        \transpose b-flat c' {
          \music
        }
      }

      \new Staff \with {
        instrumentName ="Bass Clarinet"
        shortInstrumentName = "B. Cl."
        midiInstrument = "clarinet"
      } {
        \transposition b-flat
        \transpose b-flat c' {
          \music
        }
      }

      \new Staff \with {
        instrumentName = "2 Bassoons"
        shortInstrumentName = \markup { \shared-stave "Bsn." \right-column { "1" "2" } }
        midiInstrument = "bassoon"
        \consists Merge_rests_engraver
      } {
        \clef "bass"
        \music
      }

      \new Staff \with {
        instrumentName ="Contrabassoon"
        shortInstrumentName = "Cbsn."
        midiInstrument = "bassoon"
      } {
        \clef "bass_8"
        \music
      }
    >>

    \new StaffGroup="Brass"
    <<
      \new StaffGroup="Horns" \with {
        instrumentName = "4 Horns in F"
        shortInstrumentName = \markup { \column { "Hn." "in F" } }
        systemStartDelimiter = #'SystemStartSquare
      } <<
        \new Staff \with {
          shortInstrumentName = \markup { \shared-stave \null \right-column { "1" "2" } }
          midiInstrument = "french horn"
          \consists Merge_rests_engraver
        } {
          \transposition f
          \transpose f c' {
            \music
          }
        }

        \new Staff \with {
          shortInstrumentName = \markup { \shared-stave \null \right-column { "3" "4" } }
          midiInstrument = "french horn"
          \consists Merge_rests_engraver
        } {
          \transposition f
          \transpose f c' {
            \music
          }
        }
      >>

      \new Staff \with {
        instrumentName = \markup { \append-flat "3 Trumpets in B" }
        shortInstrumentName = \markup {
          \shared-stave
            \column { "Tpt." \append-flat "in B" }
            \right-column { "1" "2" "3" }
        }
        midiInstrument = "trumpet"
        \consists Merge_rests_engraver
      } {
        \transposition b-flat
        \transpose b-flat c' {
          \music
        }
      }

      \new StaffGroup="Horns" \with {
        instrumentName = "3 Trombones"
        shortInstrumentName = "Trb."
        systemStartDelimiter = #'SystemStartSquare
      } <<
        \new Staff \with {
          shortInstrumentName = \markup { \shared-stave \null \right-column { "1" "2" } }
          midiInstrument = "trombone"
          \consists Merge_rests_engraver
        } {
          \clef "bass"
          \music
        }

        \new Staff \with {
          shortInstrumentName = \markup { \shared-stave \null \right-column { "3" } }
          midiInstrument = "trombone"
        } {
          \clef "bass"
          \music
        }
      >>

      \new Staff \with {
        instrumentName = "Tuba"
        shortInstrumentName = "Tuba"
        midiInstrument = "tuba"
      } {
        \clef "bass"
        \music
      }
    >>

    \new Staff \with {
      instrumentName = "Timpani"
      shortInstrumentName = "Timp."
      midiInstrument = "timpani"
    } {
      \clef "bass"
      \music
    }

    \new StaffGroup="Percussion" \with {
      instrumentName = "Percussion"
      shortInstrumentName = "Perc."
    } <<
      \new Staff \with {
        shortInstrumentName = \markup { \shared-stave \null "1" }
      } {
        \music
      }

      \new DrumStaff \with {
        shortInstrumentName = \markup { \shared-stave \null "2" }
      } {
        \override DrumStaff.StaffSymbol.line-count = #1
        \music
      }
    >>

    \new GrandStaff="Harp" \with {
      instrumentName = "Harp"
      shortInstrumentName = "Hrp."
      midiInstrument = "orchestral harp"
    } <<
      \new Staff="up" {
        \music
      }
      \new Staff="down" {
        \clef "bass"
        \music
      }
    >>

    \new PianoStaff="Celesta" \with {
      instrumentName = "Celesta"
      shortInstrumentName = "Cel."
      midiInstrument = "celesta"
    } <<
      \new Staff="up" {
        \clef "treble^8"
        \music
      }
      \new Staff="down" {
        \clef "bass^8"
        \music
      }
    >>

    \new StaffGroup="Strings"
    <<
      \new StaffGroup="Violins I" \with {
        instrumentName = "Violin I"
        shortInstrumentName = "Vln. I"
        systemStartDelimiter = #'SystemStartSquare
      } <<
        \new Staff \with {
          midiInstrument = "violin"
        } {
          \new Voice \with {
            \consists Mark_engraver
            \consists Metronome_mark_engraver
            \consists Staff_collecting_engraver
            \override MetronomeMark.font-size = #2
          } {
            \music
          }
        }

        \new Staff \with {
          midiInstrument = "violin"
        } {
          \music
        }
      >>

      \new StaffGroup="Violins II" \with {
        instrumentName = "Violin II"
        shortInstrumentName = "Vln. II"
        systemStartDelimiter = #'SystemStartSquare
      } <<
        \new Staff \with {
          midiInstrument = "violin"
        } {
          \music
        }

        \new Staff \with {
          midiInstrument = "violin"
        } {
          \music
        }
      >>

      \new StaffGroup="Violas" \with {
        instrumentName = "Viola"
        shortInstrumentName = "Vla."
        systemStartDelimiter = #'SystemStartSquare
      } <<
        \new Staff \with {
          midiInstrument = "viola"
        } {
          \clef "alto"
          \music
        }

        \new Staff \with {
          midiInstrument = "viola"
        } {
          \clef "alto"
          \music
        }
      >>

      \new StaffGroup="Celli" \with {
        instrumentName = "Cello"
        shortInstrumentName = "Vcl."
        systemStartDelimiter = #'SystemStartSquare
      } <<
        \new Staff \with {
          midiInstrument = "cello"
        } {
          \clef "bass"
          \music
        }

        \new Staff \with {
          midiInstrument = "cello"
        } {
          \clef "bass"
          \music
        }
      >>

      \new Staff \with {
        instrumentName = "Contrabass"
        shortInstrumentName = "Cb."
        midiInstrument = "contrabass"
      } {
        \clef "bass_8"
        \music
      }
    >>

    \new Dynamics \with {
      \consists Measure_counter_engraver
      \override MeasureCounter.direction = #DOWN
      \override MeasureCounter.font-encoding = #'latin1
      \override MeasureCounter.font-features = #'("pnum")
      \override MeasureCounter.font-size = #2
      \override VerticalAxisGroup.nonstaff-relatedstaff-spacing.padding = #2
    } {
      \startMeasureCount
      \music
      \stopMeasureCount
    }
  >>

  \layout {
    \context {
      \Score
      rehearsalMarkFormatter = #format-mark-box-alphabet
      \remove Bar_number_engraver
      \remove Mark_engraver
      \remove Metronome_mark_engraver
      \remove Staff_collecting_engraver
      \consists #Instrument_name_measuring_engraver
    }
    \context {
      \Staff
      \override ClefModifier.stencil = ##f
    }
  }
}

#(set-global-staff-size 15)

\paper {
  left-margin = 0.5\in
  top-margin = 0.5\in
  right-margin = 0.5\in
  bottom-margin = 0.5\in

  evenHeaderMarkup = \markup {
    \abs-fontsize #8
    \fill-line {
      \fromproperty #'page:page-number-string
      \null
    }
  }

  oddHeaderMarkup = \markup {
    \abs-fontsize #8
    \fill-line {
      \null
      \if \should-print-page-number \fromproperty #'page:page-number-string
    }
  }
}

\pointAndClickOff
