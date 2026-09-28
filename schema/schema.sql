-- =================================================================
-- EX 603 Assignment 2 — schema.sql
-- Theme: Social Media
-- Author: Sahid Bangura
-- Target: PostgreSQL 14+
-- =================================================================

-- Reset tables in reverse creation order.
DROP TABLE IF EXISTS post_hashtags CASCADE;
DROP TABLE IF EXISTS likes CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS hashtags CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- -----------------------------------------------------------------
-- 1. users
-- Created first because it does not reference another table.
-- -----------------------------------------------------------------
CREATE TABLE users (
    user_id INTEGER GENERATED ALWAYS AS IDENTITY,
    display_name VARCHAR(100) NOT NULL,
    CONSTRAINT pk_users PRIMARY KEY (user_id)
);

-- -----------------------------------------------------------------
-- 2. hashtags
-- Created before post_hashtags because the junction table references it.
-- -----------------------------------------------------------------
CREATE TABLE hashtags (
    hashtag_id INTEGER GENERATED ALWAYS AS IDENTITY,
    hashtag_name VARCHAR(100) NOT NULL,
    CONSTRAINT pk_hashtags PRIMARY KEY (hashtag_id),
    CONSTRAINT uq_hashtags_name UNIQUE (hashtag_name)
);

-- -----------------------------------------------------------------
-- 3. posts
-- Created after users because posts.user_id references users.user_id.
-- -----------------------------------------------------------------
CREATE TABLE posts (
    post_id INTEGER GENERATED ALWAYS AS IDENTITY,
    user_id INTEGER NOT NULL,
    post_title VARCHAR(200) NOT NULL,
    is_active BOOLEAN NOT NULL,
    view_count INTEGER NOT NULL,
    CONSTRAINT pk_posts PRIMARY KEY (post_id),
    CONSTRAINT fk_posts_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_posts_view_count
        CHECK (view_count >= 0)
);

-- -----------------------------------------------------------------
-- 4. likes
-- Created after users and posts because it references both tables.
-- -----------------------------------------------------------------
CREATE TABLE likes (
    like_id INTEGER GENERATED ALWAYS AS IDENTITY,
    user_id INTEGER NOT NULL,
    post_id INTEGER NOT NULL,
    liked_at TIMESTAMP NOT NULL,
    dwell_ms INTEGER NOT NULL,
    CONSTRAINT pk_likes PRIMARY KEY (like_id),
    CONSTRAINT fk_likes_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_likes_post
        FOREIGN KEY (post_id)
        REFERENCES posts (post_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_likes_dwell_ms
        CHECK (dwell_ms >= 0)
);

-- -----------------------------------------------------------------
-- 5. post_hashtags
-- Junction table resolving the M:N relationship between
-- posts and hashtags.
-- -----------------------------------------------------------------
CREATE TABLE post_hashtags (
    post_id INTEGER NOT NULL,
    hashtag_id INTEGER NOT NULL,
    CONSTRAINT pk_post_hashtags
        PRIMARY KEY (post_id, hashtag_id),
    CONSTRAINT fk_post_hashtags_post
        FOREIGN KEY (post_id)
        REFERENCES posts (post_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_post_hashtags_hashtag
        FOREIGN KEY (hashtag_id)
        REFERENCES hashtags (hashtag_id)
        ON DELETE CASCADE
);
