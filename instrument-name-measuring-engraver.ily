\version "2.25.0"

#(define max-text-width 0)

#(define-markup-command (short-instrument-name layout properties name) (markup?)
  (interpret-markup layout properties
    (markup #:with-dimension X `(0 . ,max-text-width) name)))

#(define (Instrument_name_measuring_engraver context)
  (let (
      (done #f)
      (extra-padding 0.2)
      (system-start-delimiters '())
      (max-X-offset 0)
      (system-start-texts '())
      (max-long-text-width 0))

    (make-engraver
      (acknowledgers
        ((system-start-delimiter-interface engraver grob source-engraver)
          (set! system-start-delimiters (cons grob system-start-delimiters)))
        ((system-start-text-interface engraver grob source-engraver)
          (set! system-start-texts (cons grob system-start-texts))))

      ((stop-translation-timestep engraver)
        (unless done
          (for-each
            (lambda (system-start-delimiter)
              (let* (
                  (padding (ly:grob-property system-start-delimiter 'padding))
                  (thickness (ly:grob-property system-start-delimiter 'thickness)))
                (unless (or (null? padding) (null? thickness))
                  (set! max-X-offset (max max-X-offset (+ padding thickness))))))
            system-start-delimiters)

          (for-each
            (lambda (system-start-text)
              (let* (
                  (layout (ly:grob-layout system-start-text))
                  (properties (ly:grob-alist-chain system-start-text (ly:output-def-lookup layout 'text-font-defaults)))
                  (long-text-X-extent (ly:stencil-extent (interpret-markup layout properties (ly:grob-property system-start-text 'long-text)) X))
                  (text-X-extent (ly:stencil-extent (interpret-markup layout properties (ly:grob-property system-start-text 'text)) X)))
                (set! max-long-text-width (max max-long-text-width (cdr long-text-X-extent)))
                (set! max-text-width (max max-text-width (cdr text-X-extent)))))
            system-start-texts)

          (let* (
              (paper (ly:parser-lookup '$defaultpaper))
              (module (ly:output-def-scope paper))
              (staff-space (variable-ref (module-variable module 'staff-space)))
              (pt (variable-ref (module-variable module 'pt)))
              (indent (* (+ max-long-text-width max-X-offset extra-padding) (/ staff-space pt)))
              (short-indent (* (+ max-text-width max-X-offset extra-padding) (/ staff-space pt))))

            ; These don’t appear to do anything:
            ; (ly:output-def-set-variable! paper 'indent indent)
            ; (ly:output-def-set-variable! paper 'short-indent short-indent)

            (unless (< (abs (- (/ (ly:paper-get-number paper 'indent) pt) indent)) 1e-9)
              (ly:message "\nYou may need to add\n  indent = ~A\\pt\nto your \\paper block.\n\n" indent))
            (when (zero? (ly:paper-get-number paper 'short-indent))
              (ly:message "\nAdd\n  short-indent = ~A\\pt\nto your \\paper block.\n\n" short-indent))
          )

          (for-each
            (lambda (system-start-text)
              (ly:grob-set-property! system-start-text 'text (markup #:with-dimension X `(0 . ,max-text-width) (ly:grob-property system-start-text 'text))))
            system-start-texts)

          (set! done #t)
          (set! system-start-delimiters '())
          (set! max-X-offset 0)
          (set! system-start-texts '())
          (set! max-long-text-width 0))))))
