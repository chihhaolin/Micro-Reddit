# Project: Micro-Reddit

## 專案目標

建立一個輕量版的 Reddit clone，練習 Rails 的資料建模與 Active Record 操作。
**不需要建立前端介面**，全程透過 `rails console` 與 Model 互動。

---

## 需要建立的 Models

| Model   | 說明           |
|---------|----------------|
| User    | 使用者帳號     |
| Post    | 用戶發布的連結/貼文 |
| Comment | 對貼文的留言   |

> 注意：Comment 只能針對 Post 留言，**不支援對 Comment 再留言**。

---

## Spec：各 Model 規格

### User
- 欄位：`username`、`email`、`password`（以及 Rails 自動產生的 `id`、`created_at`、`updated_at`）
- 驗證：
  - `username`：必填、唯一、長度限制（建議 4–12 字元）
  - `email`：必填、唯一
  - `password`：必填、長度限制（建議 6–16 字元）
- 關聯：
  - `has_many :posts`
  - `has_many :comments`

---

### Post
- 欄位：`title`、`body`（或 URL）、`user_id`（外鍵）
- 驗證：
  - `title`：必填
  - `body`：必填
  - `user_id`：必填
- 關聯：
  - `belongs_to :user`
  - `has_many :comments`

---

### Comment
- 欄位：`body`、`user_id`（外鍵）、`post_id`（外鍵）
- 驗證：
  - `body`：必填
  - `user_id`：必填（不可孤兒留言）
  - `post_id`：必填（不可孤兒留言）
- 關聯：
  - `belongs_to :user`
  - `belongs_to :post`

---

## 操作步驟

### 1. 建立專案
```bash
rails new micro-reddit
cd micro-reddit
```

### 2. 建立並執行 Migration
```bash
rails generate model User username:string email:string password:string
rails generate model Post title:string body:text user:references
rails generate model Comment body:text user:references post:references
rails db:migrate
```

> 若 migration 有誤，可用 `rails db:rollback` 回滾，或建新 migration 用 `add_column` / `remove_column` / `change_column` 修正。

### 3. 在 console 測試 User 驗證
```bash
rails console   # 或 rails c
```
```ruby
User.all                          # 應回傳空陣列
u = User.new                      # 建立但不儲存
u.valid?                          # 未加驗證前為 true，加完後應為 false
u.errors.full_messages            # 查看驗證錯誤訊息
u3 = User.new(username: "alice", email: "alice@example.com", password: "123456")
u3.valid?                         # 應為 true
u3.save                           # 儲存到資料庫
```

### 4. 測試 Post 關聯
```ruby
User.first.posts                  # 應回傳空陣列，不應報錯
p1 = Post.new(title: "Hello", body: "World", user_id: User.first.id)
p2 = User.first.posts.build       # 用關聯 build，user_id 自動填入
p1.save
Post.first.user                   # 應回傳對應的 User 物件
```

### 5. 測試 Comment 關聯
```ruby
u2 = User.find(2)
c1 = Comment.new(body: "Nice post!", user_id: u2.id, post_id: Post.first.id)
c1.save
u2.comments.first                 # 應回傳 c1
c1.user                           # 應回傳 u2
Post.first.comments.first         # 應回傳 c1
c1.post                           # 應回傳 Post.first
```

---

## 注意事項

- **不需要做登入/登出功能**，也不需要加密密碼（此階段純練習 Model）。
- 每次修改 Model 後，記得在 console 執行 `reload!`，否則變更不會生效。
- 若 `reload!` 無效，直接 `quit` 後重新開啟 console。
- 確保 Comment 的 `user_id` 與 `post_id` 兩個外鍵都有設驗證，避免產生孤兒留言。
- 使用 `build` 透過關聯建立物件時，外鍵會**自動填入**，不需手動指定。

---

## 常用指令速查

| 指令 | 說明 |
|------|------|
| `rails c` | 開啟 Rails console |
| `rails s` | 啟動 Rails server |
| `rails g model ...` | 產生 Model |
| `rails db:migrate` | 執行 migration |
| `rails db:rollback` | 回滾最後一次 migration |
| `reload!` | 在 console 中重新載入程式碼 |