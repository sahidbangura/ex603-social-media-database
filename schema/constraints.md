# Integrity Constraints

## Primary Key Constraints

- `users.user_id` is unique and not null.
- `posts.post_id` is unique and not null.
- `likes.like_id` is unique and not null.
- `hashtags.hashtag_id` is unique and not null.
- `post_hashtags` uses (`post_id`, `hashtag_id`) as a composite primary key. This prevents duplicate post-hashtag associations.

## Foreign Key Constraints and ON DELETE Behavior

### `posts.user_id` → `users.user_id`

Every post must reference an existing user.

**ON DELETE CASCADE**

If a user is deleted, that user's posts should also be removed because a post cannot exist without its owner.

### `likes.user_id` → `users.user_id`

Every like must reference an existing user.

**ON DELETE CASCADE**

If a user is deleted, that user's likes should also be removed because those interaction records would otherwise reference a user who no longer exists.

### `likes.post_id` → `posts.post_id`

Every like must reference an existing post.

**ON DELETE CASCADE**

If a post is deleted, its likes should also be deleted because those likes have no meaning without the post they describe.

### `post_hashtags.post_id` → `posts.post_id`

Every post-hashtag association must reference an existing post.

**ON DELETE CASCADE**

If a post is deleted, its hashtag associations should also be removed automatically.

### `post_hashtags.hashtag_id` → `hashtags.hashtag_id`

Every post-hashtag association must reference an existing hashtag.

**ON DELETE CASCADE**

If a hashtag is deleted, its associations should be removed while the associated posts remain.

## Domain and Uniqueness Constraints

- `display_name` is required and cannot be null.
- `post_title` is required and cannot be null.
- `is_active` must be a Boolean value.
- `view_count` must be greater than or equal to zero.
- `liked_at` must contain a valid timestamp.
- `dwell_ms` must be greater than or equal to zero.
- `hashtag_name` is required and should be unique.
- Foreign-key attributes used in required relationships cannot be null.

These constraints belong in the schema because they define valid data regardless of which application or interface writes to the database.
