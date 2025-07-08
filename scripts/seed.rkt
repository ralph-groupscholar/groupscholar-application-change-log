#lang racket

(require racket/list
         racket/string
         "../src/db.rkt"
         "../src/schema.rkt")

(define (run)
  (with-conn
   (lambda (conn)
     (for ([statement (in-list (string-split schema-sql ";"))])
       (define trimmed (string-trim statement))
       (when (and trimmed (not (string=? trimmed "")))
         (exec conn (string-append trimmed ";"))))
    (for ([entry seed-sql])
      (define sql (string-join (take entry (- (length entry) 1)) ""))
      (define params (last entry))
      (apply exec conn sql params))
     (displayln "Seeded application_change_log_changes."))))

(module+ main
  (run))
