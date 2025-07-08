#lang racket

(provide schema-sql seed-sql)

(define schema-sql
  (string-join
   (list
    "create table if not exists application_change_log_changes ("
    "  change_id serial primary key,"
    "  scholar_id text not null,"
    "  application_id text not null,"
    "  change_type text not null,"
    "  previous_value text,"
    "  new_value text,"
    "  changed_by text not null,"
    "  change_reason text not null,"
    "  changed_at timestamptz not null default now(),"
    "  source_system text not null default 'manual'"
    ");"
    "create index if not exists idx_app_change_log_app_id on application_change_log_changes(application_id);"
    "create index if not exists idx_app_change_log_scholar_id on application_change_log_changes(scholar_id);"
    "create index if not exists idx_app_change_log_changed_at on application_change_log_changes(changed_at desc);")
   "\n"))

(define seed-sql
  (list
   (list
    "insert into application_change_log_changes\n"
    "  (scholar_id, application_id, change_type, previous_value, new_value, changed_by, change_reason, source_system)\n"
    "values ($1,$2,$3,$4,$5,$6,$7,$8);"
    (list "SCH-1042" "APP-8891" "status_update" "submitted" "under_review" "ops@groupscholar.com"
          "Initial review kickoff" "ops_console"))
   (list
    "insert into application_change_log_changes\n"
    "  (scholar_id, application_id, change_type, previous_value, new_value, changed_by, change_reason, source_system)\n"
    "values ($1,$2,$3,$4,$5,$6,$7,$8);"
    (list "SCH-0997" "APP-8774" "data_correction" "GPA:3.4" "GPA:3.6" "data@groupscholar.com"
          "Transcript re-uploaded" "data_import"))
   (list
    "insert into application_change_log_changes\n"
    "  (scholar_id, application_id, change_type, previous_value, new_value, changed_by, change_reason, source_system)\n"
    "values ($1,$2,$3,$4,$5,$6,$7,$8);"
    (list "SCH-1150" "APP-9042" "document_received" "Missing:Recommendation" "Received:Recommendation" "cohort@groupscholar.com"
          "Recommender submitted" "doc_portal"))
   (list
    "insert into application_change_log_changes\n"
    "  (scholar_id, application_id, change_type, previous_value, new_value, changed_by, change_reason, source_system)\n"
    "values ($1,$2,$3,$4,$5,$6,$7,$8);"
    (list "SCH-1219" "APP-9210" "status_update" "under_review" "finalist" "review@groupscholar.com"
          "Panel consensus" "review_board"))))
