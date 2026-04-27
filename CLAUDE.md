# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Micro-Reddit is a Rails 8.1.3 learning project (from The Odin Project curriculum) — a simplified Reddit clone with Users, Posts, and Comments. Full MVC is implemented; there is **no authentication** (passwords are stored as plain text, user selection is via dropdown).

- Ruby 3.4.6
- SQLite3 for all environments (stored in `storage/`)
- Hotwire (Turbo + Stimulus) + importmap for JavaScript
- Solid Cache / Solid Queue / Solid Cable (database-backed, no Redis required)
- Playwright MCP configured in `.mcp.json` (approved via `.claude/settings.json`)

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
bin/rails test                           # run all tests (53 tests)
bin/rails test test/models/              # model tests only
bin/rails test test/controllers/         # controller tests only
bin/rails test test/integration/         # integration tests only
bin/rails test test/models/user_test.rb  # run a single test file
bin/rails test:system                    # system tests (Capybara + Selenium)
bin/rails db:test:prepare                # reset test DB before running tests
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

### Models (`app/models/`)
Three domain models with full validations and associations:
- `User` — `has_many :posts, dependent: :destroy` / `has_many :comments, dependent: :destroy`; validates username (presence, unique, 4–12 chars), email (presence, unique), password (presence, 6–16 chars)
- `Post` — `belongs_to :user` / `has_many :comments, dependent: :destroy`; validates title, body, user_id presence
- `Comment` — `belongs_to :user` / `belongs_to :post`; validates body, user_id, post_id presence

### Controllers & Routes (`config/routes.rb`)
```ruby
root "posts#index"
resources :users, only: [:index, :show, :new, :create]
resources :posts do
  resources :comments, only: [:create, :destroy]
end
```
- `UsersController`: index, show, new, create
- `PostsController`: index, show, new, create, destroy
- `CommentsController`: create, destroy (nested under posts)
- Strong parameters via `params.expect` (Rails 8 API)

### Views (`app/views/`)
Reddit-style UI with orange navbar. No edit/update views (intentional — no auth system). Comment form is embedded in `posts/show`. User selector is a dropdown (no session).

### Tests
| Layer | Files | Tests |
|-------|-------|-------|
| Model | `test/models/` | 24 |
| Controller | `test/controllers/` | 15 |
| Integration | `test/integration/` | 14 |

Integration tests cover: User→Post flow, Post+Comment lifecycle, `dependent: :destroy` cascade across all three models.

### Database
Migrations in `db/migrate/`. Schema reference in `docs/schema.md`. All three tables have proper foreign keys and indexes. `db/schema.rb` is the authoritative schema definition.

CI (`.github/workflows/ci.yml`) runs five jobs on every PR and push to `main`: `scan_ruby`, `scan_js`, `lint`, `test`, `system-test`.
