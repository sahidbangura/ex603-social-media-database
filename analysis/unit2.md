# Unit 2 Analysis

## Foreign Key Constraints

| Foreign Key | ON DELETE | Reason |
|---|---|---|
| `posts.user_id → users.user_id` | CASCADE | A post belongs to a specific user, so deleting the user should also remove that user's posts. |
| `likes.user_id → users.user_id` | CASCADE | A like represents an action by a particular user, so the like should not remain after that user is deleted. |
| `likes.post_id → posts.post_id` | CASCADE | A like has no meaning without the post it belongs to, so deleting a post should remove its likes. |
| `post_hashtags.post_id → posts.post_id` | CASCADE | If a post is deleted, its hashtag associations should also disappear. |
| `post_hashtags.hashtag_id → hashtags.hashtag_id` | CASCADE | If a hashtag is removed, its associations should be removed without deleting the posts themselves. |

## ON DELETE Reasoning

### posts.user_id
When a user is removed from the platform, their posts should also be removed because each post belongs to exactly one user. Leaving the posts behind would create records whose owner no longer exists. Therefore, `ON DELETE CASCADE` keeps the database consistent.

### likes.user_id
A like records an interaction performed by a user. If that user is deleted, the corresponding like records should also be removed. Otherwise, the database would retain interactions referencing a user who no longer exists.

### likes.post_id
Likes are meaningful only in relation to a particular post. If the post is deleted, keeping its likes would leave interaction data without the content it describes. `ON DELETE CASCADE` removes those dependent rows automatically.

### post_hashtags.post_id
The `post_hashtags` table represents associations between posts and hashtags. When a post is removed, its hashtag associations are no longer meaningful and should also be removed.

### post_hashtags.hashtag_id
If a hashtag is deleted, only the associations involving that hashtag should disappear. The posts themselves should remain because they can exist without that hashtag.

## CHECK Constraints

### chk_posts_view_count
```sql
CHECK (view_count >= 0)
```
This prevents a post from having a negative number of views. A negative view count is not meaningful and could otherwise be inserted because of an application error, bad import, or incorrect update.

### chk_likes_dwell_ms
```sql
CHECK (dwell_ms >= 0)
```
This prevents negative dwell times from being stored. Dwell time measures how long a user engaged with content, so a negative value would represent an invalid state.

## Additional Integrity Decisions

`display_name`, `post_title`, `is_active`, `view_count`, `liked_at`, and `dwell_ms` are required with `NOT NULL` where the design requires a value.

`hashtag_name` is both `NOT NULL` and `UNIQUE` so that a hashtag must have a name and the same hashtag name cannot be represented by multiple rows.

The `post_hashtags` table uses `(post_id, hashtag_id)` as its composite primary key. This prevents the same hashtag from being associated with the same post more than once.
