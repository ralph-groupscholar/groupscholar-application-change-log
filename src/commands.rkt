#lang racket

(require racket/string
         racket/list
         racket/match
         "db.rkt"
         "format.rkt")

(provide cmd-add cmd-list cmd-summary)

(define (cmd-add scholar-id application-id change-type previous-value new-value changed-by change-reason source-system)
  (with-conn
   (lambda (conn)
     (exec conn
           "insert into application_change_log_changes\n  (scholar_id, application_id, change_type, previous_value, new_value, changed_by, change_reason, source_system)\nvalues ($1,$2,$3,$4,$5,$6,$7,$8);"
           scholar-id application-id change-type previous-value new-value changed-by change-reason source-system)
     (define row
       (query-row conn
                  "select change_id, scholar_id, application_id, change_type, previous_value, new_value, changed_by, change_reason, changed_at, source_system\nfrom application_change_log_changes\nwhere scholar_id = $1 and application_id = $2\norder by change_id desc\nlimit 1;"
                  scholar-id application-id))
     (format-change row))))

(define (cmd-list [limit 10] [since #f])
  (with-conn
   (lambda (conn)
     (define rows
       (if since
           (query-list conn
                       "select change_id, scholar_id, application_id, change_type, previous_value, new_value, changed_by, change_reason, changed_at, source_system\nfrom application_change_log_changes\nwhere changed_at >= $1\norder by changed_at desc\nlimit $2;"
                       since limit)
           (query-list conn
                       "select change_id, scholar_id, application_id, change_type, previous_value, new_value, changed_by, change_reason, changed_at, source_system\nfrom application_change_log_changes\norder by changed_at desc\nlimit $1;"
                       limit)))
     (if (null? rows)
         "No change events found."
         (string-join (map format-change rows) "\n\n")))))

(define (cmd-summary [since #f])
  (with-conn
   (lambda (conn)
     (define rows
       (if since
           (query-list conn
                       "select change_type, count(*)\nfrom application_change_log_changes\nwhere changed_at >= $1\ngroup by change_type\norder by count desc;"
                       since)
           (query-list conn
                       "select change_type, count(*)\nfrom application_change_log_changes\ngroup by change_type\norder by count desc;")))
     (if (null? rows)
         "No change events found."
         (format-summary rows)))))
