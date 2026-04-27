# E2E 測試結果摘要

測試日期：2026-04-27
測試工具：Playwright MCP（Chrome）
Rails 版本：8.1.3 / Ruby 3.4.6

---

## 總覽

| 項目 | 數量 |
|------|------|
| 測試流程數 | 13 |
| 通過 | 12 |
| 發現 Bug | 1（已修復）|
| 修復後全數通過 | ✅ |
| Minitest 回歸測試 | 53 tests, 0 failures |

---

## 逐項結果

| # | 截圖 | 測試項目 | 結果 | 備註 |
|---|------|---------|------|------|
| 01 | `e2e_01_homepage.png` | 首頁空白狀態 | ✅ | "No posts yet." 正確顯示 |
| 02 | `e2e_02_register_form.png` | Register 表單 UI | ✅ | placeholder、label 正確 |
| 03 | `e2e_03_user_created.png` | User 建立成功（alice）| ✅ | Flash + profile 頁正常 |
| 04 | `e2e_04_user_validation_error.png` | 重複 username 驗證 | ✅ | "Username has already been taken" |
| — | — | Username 長度驗證（bob → 3 chars）| ✅ | "Username is too short (minimum is 4 characters)" |
| 05 | `e2e_05_new_post_form.png` | New Post 表單（user dropdown）| ✅ | 下拉顯示 alice / bobby |
| 06 | `e2e_06_post_created.png` | Post 建立成功 | ✅ | Flash + show 頁正常，留言表單出現 |
| 07 | `e2e_07_comment_created.png` | Comment 建立 | ❌ **Bug** | 見下方 Bug Report |
| 08 | `e2e_08_comment_created_fixed.png` | Comment 建立（修復後）| ✅ | "1 Comment" 計數正確 |
| 09 | `e2e_09_comment_deleted.png` | Comment 刪除 | ✅ | "Comment deleted." flash，計數歸零 |
| 10 | `e2e_10_post_deleted_cascade.png` | Post 刪除 + cascade | ✅ | Confirm dialog 出現，刪除後 DB Posts=0, Comments=0 |
| 11 | `e2e_11_users_index.png` | Users index | ✅ | alice / bobby 各自 post/comment 計數正確 |
| 12 | `e2e_12_user_show.png` | User show 頁 | ✅ | email、0 posts、0 comments 正確 |
| 13 | `e2e_13_homepage_with_posts.png` | 首頁 Post 列表 | ✅ | 最新 post 在最上方，meta 資訊完整 |

---

## Bug Report

### BUG-001：Comment 無法建立

**嚴重程度**：High（核心功能失效）
**狀態**：已修復

**症狀**：
在 post show 頁填寫 comment 表單送出後，頁面刷新但留言未出現，comment 計數維持 0。

**根本原因**：
`app/views/posts/show.html.erb` 的 comment form 使用 `form_with url:` 語法，
此語法不會將 form fields 包在 model 名稱下（`comment[body]`、`comment[user_id]`），
而是直接以裸欄位名稱（`body`、`user_id`）送出。

Controller 的 strong parameters 使用 `params.expect(comment: [:body, :user_id])`，
要求參數必須嵌套在 `comment` key 下，因此拋出：

```
ActionController::ParameterMissing: param is missing or the value is empty or invalid: comment
```

**修復方式**：
```diff
# app/views/posts/show.html.erb
- <%= form_with url: post_comments_path(@post) do |f| %>
+ <%= form_with model: [@post, Comment.new] do |f| %>
```

`form_with model:` 會自動根據 model class 決定：
- URL → `post_comments_path(@post)`（`POST /posts/:post_id/comments`）
- Scope → `comment[...]`（params 正確嵌套）

**影響範圍**：僅 `app/views/posts/show.html.erb`，controller 不需修改。

---

## 回歸測試

修復後執行完整 Minitest suite：

```
53 runs, 131 assertions, 0 failures, 0 errors, 0 skips
```

所有既有測試全數通過，bug fix 沒有引入回歸。
