# Schema Definition

## 1. users

**Relation schema:**  
`users(user_id, display_name)`

| Attribute | Domain | Key |
|---|---|---|
| `user_id` | Positive integer | Primary Key |
| `display_name` | Character string, maximum 100 characters | |

**Primary key:** `user_id`

---

## 2. posts

**Relation schema:**  
`posts(post_id, user_id, post_title, is_active, view_count)`

| Attribute | Domain | Key |
|---|---|---|
| `post_id` | Positive integer | Primary Key |
| `user_id` | Positive integer referencing `users.user_id` | Foreign Key |
| `post_title` | Character string, maximum 200 characters | |
| `is_active` | Boolean (`TRUE` or `FALSE`) | |
| `view_count` | Non-negative integer | |

**Primary key:** `post_id`

---

## 3. likes

**Relation schema:**  
`likes(like_id, user_id, post_id, liked_at, dwell_ms)`

| Attribute | Domain | Key |
|---|---|---|
| `like_id` | Positive integer | Primary Key |
| `user_id` | Positive integer referencing `users.user_id` | Foreign Key |
| `post_id` | Positive integer referencing `posts.post_id` | Foreign Key |
| `liked_at` | Timestamp | |
| `dwell_ms` | Non-negative integer measured in milliseconds | |

**Primary key:** `like_id`

---

## 4. hashtags

**Relation schema:**  
`hashtags(hashtag_id, hashtag_name)`

| Attribute | Domain | Key |
|---|---|---|
| `hashtag_id` | Positive integer | Primary Key |
| `hashtag_name` | Character string, maximum 100 characters | |

**Primary key:** `hashtag_id`

---

## 5. post_hashtags

**Relation schema:**  
`post_hashtags(post_id, hashtag_id)`

| Attribute | Domain | Key |
|---|---|---|
| `post_id` | Positive integer referencing `posts.post_id` | Composite Primary Key / Foreign Key |
| `hashtag_id` | Positive integer referencing `hashtags.hashtag_id` | Composite Primary Key / Foreign Key |

**Primary key:** (`post_id`, `hashtag_id`)

The composite primary key prevents the same hashtag from being associated with the same post more than once.
