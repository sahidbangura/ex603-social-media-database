# Constraint Justifications

## users

- `user_id` is the primary key because each user must have a unique identifier.
- `display_name` stores the name shown for each user.

## posts

- `post_id` is the primary key because each post must be uniquely identifiable.
- `user_id` is a foreign key referencing `users.user_id` because every post belongs to a user.
- `is_active` is used to indicate whether a post is currently active.
- `view_count` is a numeric attribute that can be used for filtering and analysis.

## likes

- `like_id` is the primary key because each like event must be uniquely identifiable.
- `user_id` is a foreign key referencing `users.user_id` because each like is made by a user.
- `post_id` is a foreign key referencing `posts.post_id` because each like is associated with a post.
- `liked_at` records when the like occurred.
- `dwell_ms` stores the amount of time, in milliseconds, associated with the user interaction.

## hashtags

- `hashtag_id` is the primary key because each hashtag must have a unique identifier.
- `hashtag_name` stores the text value of the hashtag.

## post_hashtags

- `post_id` is a foreign key referencing `posts.post_id`.
- `hashtag_id` is a foreign key referencing `hashtags.hashtag_id`.
- The combination of `post_id` and `hashtag_id` forms a composite primary key.
- The composite key prevents the same hashtag from being assigned to the same post more than once.
- This table resolves the many-to-many relationship between posts and hashtags.
