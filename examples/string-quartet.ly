\version "2.25.0"

\include "../instrument-name-measuring-engraver.ily"

music = {
  s1*4 \break s
}

\score {
  \new StaffGroup
  <<
    \new Staff="violin-1" \with {
      instrumentName = "Violin I"
      shortInstrumentName = "Vln. I"
      midiInstrument = "violin"
    } {
      \music
    }

    \new Staff="violin-2" \with {
      instrumentName = "Violin II"
      shortInstrumentName = "Vln. II"
      midiInstrument = "violin"
    } {
      \music
    }

    \new Staff="viola" \with {
      instrumentName = "Viola"
      shortInstrumentName = "Vla."
      midiInstrument = "viola"
    } {
      \music
    }

    \new Staff="cello" \with {
      instrumentName = "Cello"
      shortInstrumentName = "Vcl."
      midiInstrument = "cello"
    } {
      \music
    }
  >>

  \layout {
    \context {
      \Score
      \consists #Instrument_name_measuring_engraver
    }
  }
}

#(set-global-staff-size 15)

\paper {
  system-separator-markup = \slashSeparator
}

\pointAndClickOff
