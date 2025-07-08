#lang racket

(require (prefix-in db: db)
         "config.rkt")

(provide with-conn exec query-list query-row)

(define (connect)
  (define cfg (db-config))
  (db:postgresql-connect
   #:server (hash-ref cfg 'host)
   #:port (hash-ref cfg 'port)
   #:database (hash-ref cfg 'database)
   #:user (hash-ref cfg 'user)
   #:password (hash-ref cfg 'password)))

(define (with-conn thunk)
  (define conn (connect))
  (dynamic-wind
    (lambda () #t)
    (lambda () (thunk conn))
    (lambda () (db:disconnect conn))))

(define (exec conn sql . args)
  (apply db:query-exec conn sql args))

(define (query-list conn sql . args)
  (apply db:query-list conn sql args))

(define (query-row conn sql . args)
  (apply db:query-row conn sql args))
