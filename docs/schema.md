# Database Schema — Micro-Reddit

## ER Diagram

```
users
  id (PK)
  username
  email
  password
  created_at
  updated_at
    |
    |-- has_many --> posts
    |                 id (PK)
    |                 title
    |                 body
    |                 user_id (FK → users.id)
    |                 created_at
    |                 updated_at
    |                   |
    |                   |-- has_many --> comments
    |                                     id (PK)
    |-- has_many -----------------------> body
                                          user_id (FK → users.id)
                                          post_id (FK → posts.id)
                                          created_at
                                          updated_at
```

---

## Tables

### `users`

| Column     | Type     | Constraints              |
|------------|----------|--------------------------|
| id         | integer  | PK, auto-increment       |
| username   | string   | NOT NULL, UNIQUE, 4–12 chars |
| email      | string   | NOT NULL, UNIQUE         |
| password   | string   | NOT NULL, 6–16 chars     |
| created_at | datetime | NOT NULL                 |
| updated_at | datetime | NOT NULL                 |

### `posts`

| Column     | Type     | Constraints              |
|------------|----------|--------------------------|
| id         | integer  | PK, auto-increment       |
| title      | string   | NOT NULL                 |
| body       | text     | NOT NULL                 |
| user_id    | integer  | NOT NULL, FK → users.id  |
| created_at | datetime | NOT NULL                 |
| updated_at | datetime | NOT NULL                 |

### `comments`

| Column     | Type     | Constraints              |
|------------|----------|--------------------------|
| id         | integer  | PK, auto-increment       |
| body       | text     | NOT NULL                 |
| user_id    | integer  | NOT NULL, FK → users.id  |
| post_id    | integer  | NOT NULL, FK → posts.id  |
| created_at | datetime | NOT NULL                 |
| updated_at | datetime | NOT NULL                 |

---

## Associations

| Model   | Association                          |
|---------|--------------------------------------|
| User    | `has_many :posts, dependent: :destroy` |
| User    | `has_many :comments, dependent: :destroy` |
| Post    | `belongs_to :user`                   |
| Post    | `has_many :comments, dependent: :destroy` |
| Comment | `belongs_to :user`                   |
| Comment | `belongs_to :post`                   |

> Comment 只能針對 Post 留言，不支援對 Comment 再留言。

---

## Migration Commands

```bash
bin/rails generate model User username:string email:string password:string
bin/rails generate model Post title:string body:text user:references
bin/rails generate model Comment body:text user:references post:references
bin/rails db:migrate
```

## Rollback

```bash
bin/rails db:rollback STEP=3   # 回滾三個 migration
```
