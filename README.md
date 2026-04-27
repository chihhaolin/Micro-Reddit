# Micro-Reddit

A lightweight Reddit clone built with Ruby on Rails 8.1.3, following The Odin Project curriculum. The goal is to practice Rails data modelling, Active Record associations, RESTful routing, and full MVC development — without authentication.

---

## Tech Stack

| 項目 | 內容 |
|------|------|
| Ruby | 3.4.6 |
| Rails | 8.1.3 |
| Database | SQLite3（存於 `storage/`） |
| Frontend | Hotwire（Turbo + Stimulus）+ importmap |
| Background jobs / Cache / Cable | Solid Queue / Solid Cache / Solid Cable（不需要 Redis） |
| Testing | Minitest + Capybara + Selenium |
| Linting | RuboCop（rails-omakase style） |

---

## 目前完成的功能

### Models（`app/models/`）
| Model | 說明 |
|-------|------|
| `User` | 使用者帳號，has_many posts & comments |
| `Post` | 貼文，belongs_to user，has_many comments |
| `Comment` | 留言，belongs_to user & post |

所有 model 皆有完整 validations：
- `User`：username（必填、唯一、4–12 字元）、email（必填、唯一）、password（必填、6–16 字元）
- `Post`：title、body、user_id 皆必填
- `Comment`：body、user_id、post_id 皆必填
- `dependent: :destroy` 確保刪除 User/Post 時 cascade 清除子資料

### Controllers & Routes（`app/controllers/`、`config/routes.rb`）
| 路由 | Controller | Actions |
|------|------------|---------|
| `/` | PostsController | index（首頁）|
| `/posts` | PostsController | index, show, new, create, destroy |
| `/posts/:post_id/comments` | CommentsController | create, destroy |
| `/users` | UsersController | index, show, new, create |

### Views（`app/views/`）
- Reddit 風格介面（橘色 navbar、card layout）
- `posts/index` — 貼文列表，顯示作者、留言數、時間
- `posts/show` — 貼文詳情 + 留言列表 + 內嵌留言表單
- `posts/new` — 建立貼文表單（含 validation 錯誤顯示）
- `users/index` — 用戶列表，顯示 post/comment 數量
- `users/show` — 個人頁面，列出該用戶的所有貼文與留言
- `users/new` — 註冊表單

### Tests（`test/`）
| 層級 | 檔案數 | 測試數 |
|------|--------|--------|
| Model tests | 3 | 24 |
| Controller tests | 3 | 15 |
| Integration tests | 3 | 14 |
| **Minitest 合計** | **9** | **53** |
| E2E（Playwright MCP） | — | 13 flows |

Integration tests 涵蓋：User → Post 完整流程、Post + Comment 生命週期、`dependent: :destroy` cascade 驗證。

E2E tests 使用 Playwright MCP 對 dev server 進行瀏覽器操作測試，流程文件與截圖存放於 `test/e2e_playwright/`。

---

## 本地開發

### 環境需求
- Ruby 3.4.6（建議使用 rbenv 或 mise 管理）
- Bundler

### 安裝與啟動

```bash
git clone <repo-url>
cd Micro-Reddit
bin/setup        # 安裝 gems、建立並 migrate DB、啟動 dev server
```

或分步執行：

```bash
bundle install
bin/rails db:prepare
bin/dev          # 啟動開發伺服器（http://localhost:3000）
```

### 資料庫操作

```bash
bin/rails db:migrate        # 執行 migration
bin/rails db:rollback       # 回滾最後一次 migration
bin/rails db:seed           # 載入種子資料
bin/rails console           # 開啟 Rails console
```

---

## 測試

```bash
bin/rails db:test:prepare           # 重設測試資料庫
bin/rails test                      # 跑全部測試
bin/rails test test/models/         # 只跑 model tests
bin/rails test test/controllers/    # 只跑 controller tests
bin/rails test test/integration/    # 只跑 integration tests
bin/rails test test/models/user_test.rb  # 跑單一測試檔
bin/rails test:system               # 跑 system tests（Capybara）
```

---

## Linting & 安全掃描

```bash
bin/rubocop                # 檢查 Ruby 風格（rails-omakase）
bin/rubocop -a             # 自動修正
bin/brakeman --no-pager    # Rails 安全靜態分析
bin/bundler-audit          # 檢查 gem CVE
bin/importmap audit        # 檢查 JS 依賴漏洞
```

---

## 專案結構說明

```
app/
  models/          # User, Post, Comment（含 validations & associations）
  controllers/     # UsersController, PostsController, CommentsController
  views/           # posts/, users/ 各頁面
  assets/stylesheets/application.css   # Reddit 風格 CSS
config/
  routes.rb        # RESTful routes 定義
db/
  migrate/         # 三個 migration（users, posts, comments）
  schema.rb        # 自動產生的 schema 定義
docs/
  schema.md        # DB schema 參考文件（ER 圖、欄位定義）
  spec.md          # 專案規格文件
test/
  models/          # Model unit tests
  controllers/     # Controller functional tests
  integration/     # 跨資源流程 integration tests
  fixtures/        # users.yml, posts.yml, comments.yml
  e2e_playwright/  # Playwright MCP E2E 測試流程文件與截圖
```

---

## CI

GitHub Actions（`.github/workflows/ci.yml`）在每次 PR 及 push 到 `main` 時執行五個 jobs：

| Job | 內容 |
|-----|------|
| `scan_ruby` | Brakeman 靜態安全分析 |
| `scan_js` | importmap JS 依賴漏洞掃描 |
| `lint` | RuboCop 風格檢查 |
| `test` | Minitest（model + controller + integration）|
| `system-test` | Capybara + Selenium system tests |

---

## 注意事項

- 此專案**無登入/登出功能**，密碼為明文儲存（純練習 Model 關聯）
- 留言**只能對 Post 留言**，不支援對 Comment 再留言
- 選擇發文/留言的用戶透過下拉選單指定（無 session auth）
