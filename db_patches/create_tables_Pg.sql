-- GRANT ALL PRIVILEGES ON BlogsPerlOrg.* TO 'username'@'localhost' IDENTIFIED BY 'password';

-- DROP DATABASE IF EXISTS BlogsPerlOrg;
-- CREATE DATABASE IF NOT EXISTS BlogsPerlOrg;

-- USE BlogsPerlOrg;


--
-- Users can have their type chosen from this list.
-- The unique constraint on names means the names are effectively their own ID.
--
CREATE TABLE role (
  name varchar(255) NOT NULL UNIQUE,
  PRIMARY KEY (name)
);


CREATE TYPE active_state AS ENUM (
  'deactivated',
  'activated',
  'suspended',
  'pending'
);


--
-- Users now are assigned to a class when they're created.
--
CREATE TABLE "user" (
  id serial UNIQUE,
  name varchar(255) NULL,
  username varchar(200) NOT NULL UNIQUE,
  password varchar(128) NOT NULL,
  salt varchar(48) NOT NULL,
  preferred_language varchar(50) NULL,
  register_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  email varchar(255), -- weakening
  company varchar(255) DEFAULT NULL,
  telephone varchar(12) DEFAULT NULL,
  role varchar(255) NOT NULL REFERENCES role (name) DEFAULT 'author',
  activation_key varchar(100) DEFAULT NULL,
  status active_state NOT NULL DEFAULT 'deactivated'
);


--
-- User types have a set of abilities chosen from this list.
-- The unique constraint on names means the names are effectively their own ID.
--
CREATE TABLE ability (
  name varchar(255) NOT NULL UNIQUE,
  PRIMARY KEY (name)
);


--
-- Access controls for a given user type
--
CREATE TABLE acl (
  name varchar(255) NOT NULL REFERENCES role (name),
  ability varchar(255) NOT NULL REFERENCES ability (name),
  PRIMARY KEY (name,ability)
);


--
-- The blogs
--
CREATE TABLE blog (
  id serial UNIQUE,
  name varchar(512) NOT NULL,
  description varchar(512),
  created_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  edited_date timestamp,
  status active_state NOT NULL DEFAULT 'deactivated'
);


CREATE TABLE blog_owners (
  user_id integer NOT NULL REFERENCES "user" (id),
  blog_id integer NOT NULL REFERENCES blog (id),
  created_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status active_state NOT NULL DEFAULT 'deactivated',
  PRIMARY KEY (user_id,blog_id)
);


CREATE TABLE category (
  id serial UNIQUE,
  name varchar(100) NOT NULL,
  slug varchar(100) NOT NULL,
  user_id integer NOT NULL REFERENCES "user" (id)
);

CREATE TYPE post_format AS ENUM (
  'HTML',
  'Markdown'
);

CREATE TYPE post_status AS ENUM (
  'published',
  'trash',
  'draft'
);


CREATE TABLE post (
  id serial UNIQUE,
  title varchar(255) NOT NULL,
  slug varchar(255),
  description varchar(255),
  cover varchar(300),
  content text NOT NULL,
  created_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  type post_format DEFAULT 'HTML',
  status post_status DEFAULT 'draft',
  user_id integer NOT NULL REFERENCES "user" (id),
  PRIMARY KEY (id)
);


CREATE TABLE post_category (
  category_id integer NOT NULL REFERENCES category (id),
  post_id integer NOT NULL REFERENCES post (id),
  PRIMARY KEY (category_id,post_id)
);


CREATE TABLE tag (
  id serial UNIQUE,
  name varchar(100) DEFAULT NULL,
  slug varchar(100) DEFAULT NULL
);


CREATE TABLE post_tag (
  tag_id integer NOT NULL REFERENCES tag (id),
  post_id integer NOT NULL REFERENCES post (id),
  PRIMARY KEY (tag_id,post_id)
);


CREATE TYPE comment_status AS ENUM (
  'approved',
  'spam',
  'pending',
  'trash'
);


CREATE TABLE comment (
  id serial UNIQUE,
  content text,
  fullname varchar(100) DEFAULT NULL,
  email varchar(200) DEFAULT NULL,
  website varchar(255) DEFAULT NULL,
  avatar varchar(255) DEFAULT NULL,
  comment_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  type post_format DEFAULT 'HTML',
  status comment_status DEFAULT 'pending',
  post_id integer NOT NULL REFERENCES post (id),
  uid integer NOT NULL REFERENCES "user" (id),
  reply_to integer DEFAULT NULL REFERENCES comment (id)
);


CREATE TABLE settings (
  timezone varchar(255) NOT NULL,
  social_media integer NOT NULL DEFAULT '1',
  blog_path varchar(255) NOT NULL DEFAULT '/',
  theme_folder varchar(255) NOT NULL,
  blog_name varchar(255) NOT NULL,
  multiuser integer NOT NULL DEFAULT '0',
  id serial UNIQUE
);
