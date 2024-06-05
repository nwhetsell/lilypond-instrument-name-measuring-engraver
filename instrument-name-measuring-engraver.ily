\version "2.25.0"

\layout {
  \context {
    \GrandStaff
    \override InstrumentName.self-alignment-X = #RIGHT
  }
  \context {
    \PianoStaff
    \override InstrumentName.self-alignment-X = #RIGHT
  }
  \context {
    \Staff
    \override InstrumentName.self-alignment-X = #RIGHT
  }
  \context {
    \StaffGroup
    \override InstrumentName.self-alignment-X = #RIGHT
  }
}

$(let ((file-name (string-join `(,(getcwd) ".indents.ily") file-name-separator-string)))
  (when (file-exists? file-name)
    #{ \include $file-name #}
  ))

#(define (Instrument_name_measuring_engraver context)
  (let (
      (done #f)
      (system-start-delimiter-grobs-by-context '())
      (system-start-delimiter-pairs-by-context '())
      (top-level-system-start-delimiter-pairs '())
      (max-depth 0)
      (max-X-offset 0)
      (system-start-texts '())
      (max-long-text-width 0)
      (max-text-width 0))

    (make-engraver
      (acknowledgers
        ((system-start-delimiter-interface engraver grob source-engraver)
          ; Gather contexts that have a systemStartDelimiter property (usually
          ; StaffGroup contexts) into a tree of pairs such that each pair’s car
          ; is the context and cdr is a list of pairs.
          (let* (
              (context (ly:translator-context source-engraver))
              (initial-pair (assoc-ref system-start-delimiter-pairs-by-context context)))
            (set! system-start-delimiter-grobs-by-context (assoc-set! system-start-delimiter-grobs-by-context context grob))
            (unless initial-pair
              (set! initial-pair (cons context '()))
              (let recurse-ancestor-contexts (
                  (pair initial-pair)
                  (ancestor-context (ly:context-parent context)))
                (if ancestor-context
                  (let (
                      (delimiter (ly:context-property ancestor-context 'systemStartDelimiter))
                      (next-pair pair)
                      (had-pair #f))
                    (when (and delimiter
                               (not (null? delimiter)))
                      (set! next-pair (assoc-ref system-start-delimiter-pairs-by-context ancestor-context))
                      (if next-pair
                        (begin
                          (set-cdr! next-pair (cons pair (cdr next-pair)))
                          (set! had-pair #t))
                      ; else
                        (begin
                          (set! next-pair (cons ancestor-context (list pair)))
                          (set! system-start-delimiter-pairs-by-context (assoc-set! system-start-delimiter-pairs-by-context ancestor-context next-pair)))))
                    (set! context ancestor-context)
                    (unless had-pair
                      (recurse-ancestor-contexts next-pair (ly:context-parent context))))
                ; else
                  (set! top-level-system-start-delimiter-pairs (cons pair top-level-system-start-delimiter-pairs)))))))
        ((system-start-text-interface engraver grob source-engraver)
          (set! system-start-texts (cons grob system-start-texts))))

      ((stop-translation-timestep engraver)
        (unless done
          (for-each
            (lambda (top-level-system-start-delimiter-pair)
              (let recurse-pairs (
                  (pair top-level-system-start-delimiter-pair)
                  (X-offset 0)
                  (depth 0))
                (set! max-depth (max max-depth depth))
                (let* (
                    (system-start-delimiter (assoc-ref system-start-delimiter-grobs-by-context (car pair)))
                    (padding (ly:grob-property system-start-delimiter 'padding 0))
                    (thickness (ly:grob-property system-start-delimiter 'thickness 0))
                    (total-X-offset (+ X-offset padding thickness)))
                  (set! max-X-offset (max max-X-offset total-X-offset))
                  (for-each
                    (lambda (child-pair)
                      (recurse-pairs child-pair total-X-offset (1+ depth)))
                    (cdr pair))
                )
              )
            )
            top-level-system-start-delimiter-pairs)

          (for-each
            (lambda (system-start-text)
              (let* (
                  (layout (ly:grob-layout system-start-text))
                  ; Set 'font-encoding to 'latin1 to quiet warnings when creating stencils.
                  (properties (ly:grob-alist-chain system-start-text (assoc-set! (ly:output-def-lookup layout 'text-font-defaults) 'font-encoding 'latin1)))
                  (long-text-X-extent (ly:stencil-extent (interpret-markup layout properties (ly:grob-property system-start-text 'long-text)) X))
                  (text-X-extent (ly:stencil-extent (interpret-markup layout properties (ly:grob-property system-start-text 'text)) X)))
                (set! max-long-text-width (max max-long-text-width (cdr long-text-X-extent)))
                (set! max-text-width (max max-text-width (cdr text-X-extent)))))
            system-start-texts)

          (let* (
              (extra-padding (- -0.7 (* 0.25 max-depth)))
              (paper (ly:parser-lookup '$defaultpaper))
              (module (ly:output-def-scope paper))
              (staff-space (variable-ref (module-variable module 'staff-space)))
              (pt (variable-ref (module-variable module 'pt)))
              (indent (* (+ max-long-text-width max-X-offset extra-padding) (/ staff-space pt)))
              (short-indent (* (+ max-text-width max-X-offset extra-padding) (/ staff-space pt))))

            ; These don’t appear to do anything:
            ;
            ; (ly:output-def-set-variable! paper 'indent indent)
            ; (ly:output-def-set-variable! paper 'short-indent short-indent)
            ;
            ; See also
            ; https://lists.gnu.org/archive/html/lilypond-user/2024-01/msg00030.html

            (let* (
                (file-name (string-join `(,(getcwd) ".indents.ily") file-name-separator-string))
                (output-port (open-output-file file-name)))
              (format output-port "\\paper {\n  indent = ~A\\pt\n  short-indent = ~A\\pt % from max width of ~A staff spaces\n}\n" indent short-indent max-text-width)
              (close-output-port output-port)
              (unless (and (< (abs (- (/ (ly:paper-get-number paper 'indent) pt) indent)) 1e-9)
                           (< (abs (- (/ (ly:paper-get-number paper 'short-indent) pt) short-indent)) 1e-9))
                (ly:message "\nIndents have changed; you may need to re-run lilypond.\n\n"))))

          (set! done #t))

        (for-each
          (lambda (system-start-text)
            (ly:grob-set-property! system-start-text 'text (markup #:with-dimension X `(0 . ,max-text-width) (ly:grob-property system-start-text 'text))))
          system-start-texts)

        (set! system-start-texts '())))))
