# lilypond-instrument-name-measuring-engraver

You can use the file [instrument-name-measuring-engraver.ily](instrument-name-measuring-engraver.ily) in this repository with LilyPond v2.25.0 or later to make instrument names in scores more closely match the example in [Elaine Gould, _Behind Bars_ (London: Faber Music, 2011)](https://www.fabermusic.com/shop/behind-bars-the-definitive-guide-to-music-notation-p6284), p 509. To do this:

1. Add

    ```ly
    \include "lilypond-instrument-name-measuring-engraver/instrument-name-measuring-engraver.ily"
    ```

    and

    ```ly
    \layout {
      \context {
        \Score
        \consists #Instrument_name_measuring_engraver
      }
    }
    ```

    to your LilyPond file.

1. Run `lilypond` on the LilyPond file *twice*. The first time you run `lilypond`, two files will be written: an .indents.ily file with a [`\paper` block](https://lilypond.org/doc/Documentation/notation/the-paper-block) that contains indents to align instrument names to the left margin, and a .short-instrument-name-width.scm file with the maximum width of short instrument names (used on all staves but the first). In subsequent runs of `lilypond`, these files will be used to align instrument names.

Note that if you declare a `\paper` block after `\include`-ing this engraver, and the `\paper` block sets indents, the indents in the subsequent `\paper` block will take precedence over the indents in .indents.ily. Consequently, because `set-paper-size` sets indents, you must set paper size *before* `\include`-ing this engraver. For example, this will result in misalignment:

```ly
\include "lilypond-instrument-name-measuring-engraver/instrument-name-measuring-engraver.ily"
\paper {
  #(set-paper-size "11x17")
  system-separator-markup = \slashSeparator
}
```

You must do this instead:

```ly
\paper { #(set-paper-size "11x17") }
\include "lilypond-instrument-name-measuring-engraver/instrument-name-measuring-engraver.ily"
\paper {
  system-separator-markup = \slashSeparator
}
```
