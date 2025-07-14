#lang racket

(require racket/match)

(provide format-change format-summary format-group-summary)

(define (format-change row)
  (match-define (vector change-id scholar-id application-id change-type previous-value new-value changed-by change-reason changed-at source-system) row)
  (string-join
   (list
    (format "#~a | ~a | ~a" change-id application-id scholar-id)
    (format "  type: ~a" change-type)
    (format "  from: ~a" (or previous-value "-"))
    (format "  to: ~a" (or new-value "-"))
    (format "  by: ~a" changed-by)
    (format "  reason: ~a" change-reason)
    (format "  at: ~a" changed-at)
    (format "  source: ~a" source-system))
   "\n"))

(define (format-group-summary rows label)
  (define header (format "~a | Count" label))
  (define lines
    (for/list ([row rows])
      (match-define (vector group-value count) row)
      (format "~a | ~a" group-value count)))
  (string-join (cons header lines) "\n"))

(define (format-summary rows)
  (format-group-summary rows "Change Type"))
