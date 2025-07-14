#lang racket

(require rackunit
         "../src/format.rkt")

(define sample-row
  (vector 3 "SCH-100" "APP-200" "status_update" "submitted" "under_review" "ops@groupscholar.com" "Kickoff" "2026-02-01T10:00:00Z" "ops_console"))

(check-true (string-contains? (format-change sample-row) "#3 | APP-200 | SCH-100"))
(check-true (string-contains? (format-change sample-row) "type: status_update"))

(define summary-rows (list (vector "status_update" 4) (vector "data_correction" 2)))
(check-equal? (format-summary summary-rows)
              (string-join
               (list "Change Type | Count"
                     "status_update | 4"
                     "data_correction | 2")
               "\n"))

(define source-rows (list (vector "ops_console" 3) (vector "review_portal" 1)))
(check-equal? (format-group-summary source-rows "Source System")
              (string-join
               (list "Source System | Count"
                     "ops_console | 3"
                     "review_portal | 1")
               "\n"))
