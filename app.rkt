#lang racket

(require racket/cmdline
         racket/string
         racket/vector
         "src/commands.rkt")

(define (usage)
  (displayln "groupscholar-application-change-log")
  (displayln "")
  (displayln "Commands:")
  (displayln "  add --scholar SCH-123 --application APP-456 --type status_update --from submitted --to under_review --by ops@groupscholar.com --reason \"Initial review\" [--source ops_console]")
  (displayln "  list [--limit 10] [--since 2026-02-01T00:00:00Z]")
  (displayln "  summary [--since 2026-02-01T00:00:00Z]")
  (displayln "")
  (displayln "Environment: PGHOST PGPORT PGDATABASE PGUSER PGPASSWORD"))

(define (require-arg name value)
  (when (or (not value) (string=? value ""))
    (error 'cli (format "Missing required argument: ~a" name))))

(define command
  (and (>= (vector-length (current-command-line-arguments)) 1)
       (vector-ref (current-command-line-arguments) 0)))

(define rest-args
  (if command
      (vector->list (vector-drop (current-command-line-arguments) 1))
      '()))

(define (run)
  (cond
    [(or (not command) (member command '("-h" "--help" "help")))
     (usage)]
    [(string=? command "add")
     (define scholar-id #f)
     (define application-id #f)
     (define change-type #f)
     (define previous-value #f)
     (define new-value #f)
     (define changed-by #f)
     (define change-reason #f)
     (define source-system "manual")
     (command-line
      #:program "groupscholar-application-change-log add"
      #:argv (list->vector rest-args)
      ["--scholar" id "Scholar ID" (set! scholar-id id)]
      ["--application" id "Application ID" (set! application-id id)]
      ["--type" type "Change type" (set! change-type type)]
      ["--from" from "Previous value" (set! previous-value from)]
      ["--to" to "New value" (set! new-value to)]
      ["--by" by "Changed by" (set! changed-by by)]
      ["--reason" reason "Change reason" (set! change-reason reason)]
      ["--source" source "Source system" (set! source-system source)])
     (for ([pair (list (cons "--scholar" scholar-id)
                       (cons "--application" application-id)
                       (cons "--type" change-type)
                       (cons "--by" changed-by)
                       (cons "--reason" change-reason))])
       (require-arg (car pair) (cdr pair)))
     (displayln
      (cmd-add scholar-id application-id change-type previous-value new-value changed-by change-reason source-system))]
    [(string=? command "list")
     (define limit 10)
     (define since #f)
     (command-line
      #:program "groupscholar-application-change-log list"
      #:argv (list->vector rest-args)
      ["--limit" l "Limit" (set! limit (string->number l))]
      ["--since" s "Since timestamp" (set! since s)])
     (displayln (cmd-list limit since))]
    [(string=? command "summary")
     (define since #f)
     (command-line
      #:program "groupscholar-application-change-log summary"
      #:argv (list->vector rest-args)
      ["--since" s "Since timestamp" (set! since s)])
     (displayln (cmd-summary since))]
    [else
     (displayln (format "Unknown command: ~a" command))
     (usage)]))

(module+ main
  (run))
