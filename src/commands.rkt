#lang racket

(require racket/string
         racket/list
         racket/match
         "db.rkt"
         "format.rkt")

(provide cmd-add cmd-list cmd-summary)

(define allowed-groups
  (hash "type" "change_type"
        "source" "source_system"
        "by" "changed_by"
        "reason" "change_reason"))

(define (normalize-group group)
  (hash-ref allowed-groups (or group "type") "change_type"))

(define (group-label group)
  (match group
    ["source" "Source System"]
    ["by" "Changed By"]
    ["reason" "Change Reason"]
    [_ "Change Type"]))

(define (add-filter filters sql-frag value)
  (if value
      (append filters (list (cons sql-frag value)))
      filters))

(define (build-where filters)
  (define conditions
    (for/list ([pair filters] [idx (in-naturals 1)])
      (format "~a$~a" (car pair) idx)))
  (if (null? conditions)
      ""
      (string-append "where " (string-join conditions " and "))))

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

(define (cmd-list [limit 10] [since #f] [scholar-id #f] [application-id #f] [change-type #f] [changed-by #f] [source-system #f])
  (with-conn
   (lambda (conn)
     (define filters '())
     (set! filters (add-filter filters "changed_at >= " since))
     (set! filters (add-filter filters "scholar_id = " scholar-id))
     (set! filters (add-filter filters "application_id = " application-id))
     (set! filters (add-filter filters "change_type = " change-type))
     (set! filters (add-filter filters "changed_by = " changed-by))
     (set! filters (add-filter filters "source_system = " source-system))
     (define where-clause (build-where filters))
     (define sql
       (string-append
        "select change_id, scholar_id, application_id, change_type, previous_value, new_value, changed_by, change_reason, changed_at, source_system\n"
        "from application_change_log_changes\n"
        where-clause
        "\norder by changed_at desc\nlimit $"
        (number->string (add1 (length filters)))
        ";"))
     (define args (append (map cdr filters) (list limit)))
     (define rows (apply query-list conn sql args))
     (if (null? rows)
         "No change events found."
         (string-join (map format-change rows) "\n\n")))))

(define (cmd-summary [since #f] [group #f])
  (with-conn
   (lambda (conn)
     (define group-column (normalize-group group))
     (define label (group-label (or group "type")))
     (define rows
       (if since
           (query-list conn
                       (format "select ~a, count(*)\nfrom application_change_log_changes\nwhere changed_at >= $1\ngroup by ~a\norder by count desc;"
                               group-column group-column)
                       since)
           (query-list conn
                       (format "select ~a, count(*)\nfrom application_change_log_changes\ngroup by ~a\norder by count desc;"
                               group-column group-column))))
     (if (null? rows)
         "No change events found."
         (format-group-summary rows label)))))
