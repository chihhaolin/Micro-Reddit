# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Micro-Reddit is a Rails 8.1.3 learning project (from The Odin Project curriculum) that models a simplified Reddit clone — users, posts, and comments — using only models and associations, with no views or controllers initially.

- Ruby 3.4.6
- SQLite3 for all environments (stored in `storage/`)
- Hotwire (Turbo + Stimulus) + importmap for JavaScript
- Solid Cache / Solid Queue / Solid Cable (database-backed, no Redis required)

## Commands

```bash
bin/setup              # install gems, prepare DB, start dev server
bin/dev                # start dev server only
bin/rails db:prepare   # create and migrate DB
bin/rails db:seed      # seed data
bin/rails console      # open Rails console
```

### Testing
```bash
bin/rails test                        # run all unit/integration tests
bin/rails test test/models/user_test.rb  # run a single test file
bin/rails test:system                 # run system tests (Capybara + Selenium)
bin/rails db:test:prepare             # reset test DB before running tests
```

Tests use Minitest, parallelized across processors, with fixtures (`test/fixtures/`).

### Linting & Security
```bash
bin/rubocop                # lint Ruby (rails-omakase style)
bin/rubocop -a             # auto-correct offenses
bin/brakeman --no-pager    # static security analysis
bin/bundler-audit          # check gems for known CVEs
bin/importmap audit        # check JS deps for vulnerabilities
```

## Architecture

This project is **model-only** in its initial phase — no controllers or views yet. The focus is on Active Record models, validations, and associations.

Expected domain models (to be built):
- `User` — has many posts, has many comments
- `Post` — belongs to user, has many comments
- `Comment` — belongs to user, belongs to post

Database migrations live in `db/migrate/`. The schema file is `db/schema.rb` (generated after first migration).

RuboCop style inherits from `rubocop-rails-omakase` with no overrides currently.

CI (`.github/workflows/ci.yml`) runs five jobs on every PR and push to `main`: `scan_ruby`, `scan_js`, `lint`, `test`, `system-test`.
