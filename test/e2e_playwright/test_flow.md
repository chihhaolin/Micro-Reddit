# E2E 測試流程文件

使用工具：Playwright MCP（`@playwright/mcp`，Chrome 瀏覽器）
測試日期：2026-04-27
測試環境：`http://localhost:3000`（Rails 8.1.3 development server）

---

## 測試前置作業

1. 確認 `.mcp.json` 中有設定 `playwright` server
2. 確認 `.claude/settings.json` 的 `enabledMcpjsonServers` 包含 `"playwright"`
3. **清空舊截圖**：`rm -f test/e2e_playwright/e2e_*.png`
4. 啟動 Rails dev server：`bin/rails server -d -p 3000`
5. 確認 DB 已準備好（乾淨狀態）：`bin/rails db:drop db:create db:migrate`

---

## 測試流程

### Flow 1：首頁空白狀態

**目的**：確認空 DB 下首頁正常顯示。

**步驟：**
1. 瀏覽 `GET /`
2. 截圖 → `e2e_01_homepage.png`

**預期結果：**
- 顯示 orange navbar（Micro Reddit / New Post / Users / Register）
- 主區塊顯示 "All Posts" + "No posts yet. Be the first to post!"

---

### Flow 2：Register 新 User（正常路徑）

**目的**：驗證使用者建立流程。

**步驟：**
1. 點 navbar 的 Register → `GET /users/new`
2. 填入 Username: `alice`、Email: `alice@example.com`、Password: `password123`
3. 截圖表單 → `e2e_02_register_form.png`
4. 點 Register 按鈕 → `POST /users`
5. 截圖結果 → `e2e_03_user_created.png`

**預期結果：**
- 跳轉到 `GET /users/1`
- 顯示 flash "User created successfully."
- 顯示 alice 的 profile（0 posts、0 comments）

---

### Flow 3：Register 驗證錯誤（重複 username）

**目的**：確認 model 層 uniqueness validation 有反映到 UI。

**步驟：**
1. 瀏覽 `GET /users/new`
2. 填入已存在的 Username: `alice`，不同 Email
3. 點 Register
4. 截圖錯誤 → `e2e_04_user_validation_error.png`

**預期結果：**
- 停留在 `/users/new`
- 顯示錯誤訊息 "Username has already been taken"

---

### Flow 4：Register 驗證錯誤（username 太短）

**目的**：確認 length validation 正確運作。

**步驟：**
1. 嘗試 Username: `bob`（3 字元，min 為 4）

**預期結果：**
- 顯示 "Username is too short (minimum is 4 characters)"

---

### Flow 5：建立第二個 User

**步驟：**
1. 填入 Username: `bobby`、Email: `bob@example.com`、Password: `bobpass1`
2. 送出

**預期結果：**
- 跳轉到 `GET /users/2`，顯示 bobby 的 profile

---

### Flow 6：建立 Post

**目的**：驗證 post 建立流程，含 user 下拉選單。

**步驟：**
1. 點 navbar New Post → `GET /posts/new`
2. "Post as" 下拉選 `alice`
3. Title: `Hello Micro Reddit!`，Body: `This is my first post. Rails is awesome!`
4. 截圖表單 → `e2e_05_new_post_form.png`
5. 點 Post 按鈕 → `POST /posts`
6. 截圖結果 → `e2e_06_post_created.png`

**預期結果：**
- 跳轉到 `GET /posts/1`
- Flash "Post created successfully."
- 顯示 post 內容、作者 alice、"0 Comments"
- 頁面底部有 Leave a Comment 表單

---

### Flow 7：建立 Comment（發現 Bug）

**目的**：驗證 comment 建立流程。

**步驟：**
1. 在 `GET /posts/1` 的 comment 表單選 `bobby`，填入留言內容
2. 點 Comment 按鈕 → `POST /posts/1/comments`

**預期結果（應該）：**
- 頁面更新，comment 數 +1，留言顯示在列表

**實際結果（截圖 `e2e_07_comment_created.png`）：**
- 停留在 `/posts/1`，comment 數仍為 0
- Rails log 顯示：`ActionController::ParameterMissing: param is missing: comment`

**根本原因：**
`show.html.erb` 的 comment form 使用 `form_with url:` 而非 `form_with model:`，
前者不會 wrap 欄位成 `comment[body]` / `comment[user_id]`，
導致 controller 的 `params.expect(comment: [:body, :user_id])` 找不到參數。

**修正（`app/views/posts/show.html.erb:38`）：**
```erb
# 修正前
<%= form_with url: post_comments_path(@post) do |f| %>

# 修正後
<%= form_with model: [@post, Comment.new] do |f| %>
```

---

### Flow 8：建立 Comment（修正後）

**步驟：**
1. 重新填入 comment 表單（bobby，內容："Great first post! I totally agree about Rails."）
2. 送出
3. 截圖結果 → `e2e_08_comment_created_fixed.png`

**預期結果：**
- Flash "Comment added."
- "1 Comment" 正確顯示
- 留言列表顯示 bobby 的留言與 delete 連結

---

### Flow 9：刪除 Comment

**步驟：**
1. 點留言旁的 `delete` 按鈕 → `DELETE /posts/1/comments/1`
2. 截圖結果 → `e2e_09_comment_deleted.png`

**預期結果：**
- Flash "Comment deleted."
- 計數回到 "0 Comments"，顯示 "No comments yet."

---

### Flow 10：刪除 Post（cascade）

**目的**：驗證 `dependent: :destroy` cascade 正確清除 comments。

**步驟：**
1. 在 post show 頁新增一筆 comment（alice）
2. 點 Delete post 按鈕 → 出現 confirm dialog："Delete this post and all its comments?"
3. 接受 dialog → `DELETE /posts/1`
4. 截圖結果 → `e2e_10_post_deleted_cascade.png`

**預期結果：**
- 跳轉回 `GET /posts`
- Flash "Post deleted."
- 首頁顯示 "No posts yet."
- DB 確認：`Post.count == 0`，`Comment.count == 0`

---

### Flow 11：Users index

**步驟：**
1. 點 navbar Users → `GET /users`
2. 截圖 → `e2e_11_users_index.png`

**預期結果：**
- 列出 alice、bobby
- 各自顯示 posts 數與 comments 數
- 下方有 "Register new user" 按鈕

---

### Flow 12：User show

**步驟：**
1. 點 alice 的 username 連結 → `GET /users/1`
2. 截圖 → `e2e_12_user_show.png`

**預期結果：**
- 顯示 alice 的 email、post/comment 計數
- 分別列出 "Posts by Alice" 與 "Comments by Alice"
- 有 "← All Users" 返回按鈕

---

### Flow 13：首頁 Post 列表有資料

**目的**：驗證 post 列表排序與 meta 資訊。

**步驟：**
1. 以 alice 建立 post "Ask Micro Reddit: Favourite Rails gem?"
2. 以 bobby 建立 post "Micro Reddit is live!"
3. 瀏覽首頁
4. 截圖 → `e2e_13_homepage_with_posts.png`

**預期結果：**
- 最新的 post 排最上面
- 每筆 post 顯示：標題、作者連結、留言數、時間
