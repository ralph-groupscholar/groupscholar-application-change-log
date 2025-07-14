# GroupScholar Application Change Log

A Racket CLI for tracking and summarizing application record changes. It records what changed, why it changed, and who updated it, so ops and review teams can audit application adjustments without searching multiple systems.

## Features
- Log status updates, data corrections, and document receipts with reasons and provenance.
- List recent changes or filter by timestamp, scholar, application, and source metadata.
- Summarize change volume by type, source system, actor, or reason for daily reviews.

## Tech
- Racket
- PostgreSQL (production)

## Setup
1. Install Racket.
2. Set environment variables for the production database connection:

```
export PGHOST=...
export PGPORT=...
export PGDATABASE=...
export PGUSER=...
export PGPASSWORD=...
```

## Usage
```
# Add a change
racket app.rkt add --scholar SCH-1042 --application APP-8891 --type status_update --from submitted --to under_review --by ops@groupscholar.com --reason "Initial review kickoff" --source ops_console

# List recent changes
racket app.rkt list --limit 10

# Filter by scholar and source
racket app.rkt list --scholar SCH-1042 --source ops_console --limit 5

# Summarize changes
racket app.rkt summary --since 2026-02-01T00:00:00Z

# Summarize changes by source system
racket app.rkt summary --group source --since 2026-02-01T00:00:00Z
```

## Seed the Production Database
This project is designed to use the production database only. Run the seed script with production credentials to create tables and insert sample data:

```
racket scripts/seed.rkt
```

## Testing
```
raco test tests/format_test.rkt
```
