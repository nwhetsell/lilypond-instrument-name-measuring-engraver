\version "2.25.0"

#(define indents-file-name ".indents.ily")
#(define indents-file-exists (file-exists? (string-join `(,(getcwd) ,indents-file-name) file-name-separator-string)))
#(define short-instrument-name-width-file-name ".short-instrument-name-width.scm")
#(define max-indent -inf.0)
#(define max-short-indent -inf.0)
#(define max-short-instrument-name-width -inf.0)

\layout {
  \context {
    \Score
    \override InstrumentName.self-alignment-X = #RIGHT
    \override InstrumentName.X-offset = #(lambda (grob)
      (let ((x-offset (system-start-text::calc-x-offset grob)))
        (unless indents-file-exists
          (let* (
            (abs-x-offset (abs x-offset))
            (x-extent (ly:grob-extent grob (ly:grob-system grob) X))
            (width (cdr x-extent))
            (updated-metrics #f))

          (if (moment<=? (ly:grob-property (ly:spanner-bound grob LEFT) 'when) ZERO-MOMENT)
            (when (> abs-x-offset max-indent)
              (set! max-indent abs-x-offset)
              (set! updated-metrics #t))
          ; else
            (begin
              (when (> abs-x-offset max-short-indent)
                (set! max-short-indent abs-x-offset)
                (set! updated-metrics #t))
              (when (> width max-short-instrument-name-width)
                (set! max-short-instrument-name-width width)
                (set! updated-metrics #t))))

          (when updated-metrics
            (let* (
                (paper (ly:parser-lookup '$defaultpaper))
                (module (ly:output-def-scope paper))
                (staff-space (variable-ref (module-variable module 'staff-space)))
                (pt (variable-ref (module-variable module 'pt)))
                (indent (* max-indent (/ staff-space pt)))
                (short-indent (* max-short-indent (/ staff-space pt))))
              (let* (
                  (file-name (string-join `(,(getcwd) ,indents-file-name) file-name-separator-string))
                  (output-port (open-output-file file-name)))
                (format output-port
                        "\\paper {\n  indent = ~A\\pt\n  short-indent = ~A\\pt\n}\n"
                        indent
                        short-indent)
                (close-output-port output-port))
              (let* (
                  (file-name (string-join `(,(getcwd) ,short-instrument-name-width-file-name) file-name-separator-string))
                  (output-port (open-output-file file-name)))
                (format output-port "(define short-instrument-name-width ~A)\n" max-short-instrument-name-width)
                (close-output-port output-port))))))

        x-offset))
  }
}

#(define-markup-command (shared-stave layout properties instrument numeral-column) (markup? markup?)
  (interpret-markup layout properties
    (let ((file-name (string-join `(,(getcwd) ,short-instrument-name-width-file-name) file-name-separator-string)))
      (if indents-file-exists
        (begin
          (load file-name)
          #{
            \markup {
              \override #'(baseline-skip . 2.5)
              \override #`(line-width . ,short-instrument-name-width)
              \fill-line {
                \vcenter {
                  #instrument
                  #numeral-column
                }
              }
            }
          #})
      ; else
        #{
          \markup {
            \override #'(baseline-skip . 2.5)
            \concat {
              \vcenter {
                #instrument
                \hspace #1
                #numeral-column
              }
            }
          }
        #}))))

$(let ((file-name (string-join `(,(getcwd) ,indents-file-name) file-name-separator-string)))
  (when (file-exists? file-name)
    #{ \include $file-name #}))

#(define (Instrument_name_measuring_engraver context)
  (let ((system-start-texts '()))

    (make-engraver
      (acknowledgers
        ((system-start-text-interface engraver grob source-engraver)
          (set! system-start-texts (cons grob system-start-texts))))

      ((stop-translation-timestep engraver)
        (let ((file-name (string-join `(,(getcwd) ,short-instrument-name-width-file-name) file-name-separator-string)))
          (when (file-exists? file-name)
            (load file-name)
            (for-each
              (lambda (system-start-text)
                (ly:grob-set-property! system-start-text 'text (markup #:with-dimension X `(0 . ,short-instrument-name-width) (ly:grob-property system-start-text 'text))))
              system-start-texts)))

        (set! system-start-texts '())))))
