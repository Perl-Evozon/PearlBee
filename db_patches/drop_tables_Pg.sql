--
-- Drop all tables and types in reverse order of creation.
--

DROP TABLE settings;
DROP TABLE comment;

DROP TYPE comment_status;

DROP TABLE post_tag;
DROP TABLE page_tag;
DROP TABLE tag;
DROP TABLE post_category;
DROP TABLE page_category;
DROP TABLE blog_categories;
DROP TABLE category;
DROP TABLE asset;
DROP TABLE post;
DROP TABLE page;

DROP TYPE post_status;
DROP TABLE post_format;

DROP TABLE blog_owners;
DROP TABLE blog;
DROP TABLE acl;
DROP TABLE ability;
DROP TABLE user_oauth;
DROP TABLE oauth;
DROP TABLE users;
DROP TABLE theme;

DROP TYPE active_state;

DROP TABLE role;
