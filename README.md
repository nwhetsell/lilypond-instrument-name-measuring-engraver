# lilypond-instrument-name-measuring-engraver

You can use the file [instrument-name-measuring-engraver.ily](instrument-name-measuring-engraver.ily) in this repository with LilyPond v2.25.0 or later to make instrument names in scores more closely match the example in [Elaine Gould, _Behind Bars_ (London: Faber Music, 2011)](https://www.fabermusic.com/shop/behind-bars-the-definitive-guide-to-music-notation-p6284), p 509. To do this:

1. Add

    ```ly
    \include "lilypond-instrument-name-measuring-engraver/instrument-name-measuring-engraver.ily"
    ```

    to your LilyPond file.

2. Run `lilypond` on the LilyPond file *twice*. The first time you run `lilypond`, an .indents.ily file will be written with a [`\paper` block](https://lilypond.org/doc/Documentation/notation/the-paper-block) that contains indents to align instrument names to the left margin. In subsequent runs of `lilypond`, the .indents.ily file will be `\include`d, and the indents will be used.

Note that if you declare a `\paper` block after `\include`-ing this engraver, and the `\paper` block sets indents, the indents in the subsequent `\paper` block will take precedence over the indents in .indents.ily. Consequently, because `set-paper-size` sets indents, you must set paper size *before* `\include`-ing this engraver. For example, this will result in indents in .indents.ily being unused:

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
