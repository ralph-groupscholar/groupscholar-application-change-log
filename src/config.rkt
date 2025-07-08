#lang racket

(provide get-env db-config)

(define (get-env key [default #f])
  (define val (getenv key))
  (if (and val (not (string=? val ""))) val default))

(define (db-config)
  (define host (get-env "PGHOST"))
  (define port-str (get-env "PGPORT"))
  (define db (get-env "PGDATABASE"))
  (define user (get-env "PGUSER"))
  (define password (get-env "PGPASSWORD"))
  (define port (and port-str (string->number port-str)))
  (define missing
    (filter identity
            (list (and (not host) "PGHOST")
                  (and (not port) "PGPORT")
                  (and (not db) "PGDATABASE")
                  (and (not user) "PGUSER")
                  (and (not password) "PGPASSWORD"))))
  (when (pair? missing)
    (error 'db-config
           (string-append "Missing required environment variables: "
                          (string-join missing ", "))))
  (hash 'host host
        'port port
        'database db
        'user user
        'password password))
