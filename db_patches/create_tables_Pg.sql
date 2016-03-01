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
  'inactive',
  'active',
  'suspended',
  'pending'
);

CREATE TABLE theme (
  name varchar(255) NOT NULL UNIQUE,
  PRIMARY KEY (name)
);

--
-- Users now are assigned to a class when they're created.
--
CREATE TABLE users (
  id serial UNIQUE,
  name varchar(255) NULL,
  username varchar(200) NOT NULL UNIQUE,
  password varchar(128) NOT NULL,
  preferred_language varchar(50) NULL,
  theme varchar(255) NOT NULL REFERENCES theme (name) DEFAULT 'dark',
  biography text DEFAULT NULL,
  register_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  email varchar(255), -- weakening
  avatar_path varchar(255) DEFAULT NULL,
  company varchar(255) DEFAULT NULL,
  telephone varchar(12) DEFAULT NULL,
  role varchar(255) NOT NULL REFERENCES role (name) DEFAULT 'author',
  activation_key varchar(100) DEFAULT NULL,
  status active_state NOT NULL DEFAULT 'inactive'
);


--
-- OAuth servers should come from a set of legitimate service names.
--
CREATE TABLE oauth (
  name varchar(255) NOT NULL UNIQUE,
  PRIMARY KEY (name)
);


--
-- Users can authenticate themselves via LinkedIn, Facebook &c.
--
CREATE TABLE user_oauth (
  user_id integer NOT NULL REFERENCES users (id),
  name varchar(255) NOT NULL REFERENCES oauth (name),
  service_id varchar(255) NOT NULL,
  PRIMARY KEY (user_id, name, service_id)
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
  slug varchar(512) NOT NULL,
  description varchar(512),
  created_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  edited_date timestamp,
  status active_state NOT NULL DEFAULT 'inactive',
  email_notification integer NOT NULL DEFAULT '0' -- Because mySQL lacks bool type
);


CREATE TABLE blog_owners (
  user_id integer NOT NULL REFERENCES users (id),
  blog_id integer NOT NULL REFERENCES blog (id),
  created_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status active_state NOT NULL DEFAULT 'inactive',
  PRIMARY KEY (user_id,blog_id)
);


CREATE TABLE category (
  id serial UNIQUE,
  name varchar(100) NOT NULL,
  slug varchar(100) NOT NULL,
  user_id integer NOT NULL REFERENCES users (id)
);


CREATE TABLE blog_categories (
  blog_id integer NOT NULL REFERENCES "blog" (id),
  category_id integer NOT NULL REFERENCES "category" (id)
);


CREATE TABLE post_format (
  name varchar(255) NOT NULL UNIQUE,
  PRIMARY KEY (name)
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
  summary text NOT NULL,
  content text NOT NULL,
  created_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  type varchar(255) NOT NULL DEFAULT 'HTML' REFERENCES post_format (name),
  status post_status DEFAULT 'draft',
  user_id integer NOT NULL REFERENCES users (id),
  PRIMARY KEY (id)
);


CREATE TABLE asset (
  id serial NOT NULL,
  blog_id integer NOT NULL REFERENCES blog (id),
  user_id integer NOT NULL REFERENCES users (id),
  file_ext varchar(20) NOT NULL,
  file_name varchar(255) NOT NULL,
  file_path varchar(255) NOT NULL
);


CREATE TABLE post_category (
  category_id integer NOT NULL REFERENCES category (id),
  post_id integer NOT NULL REFERENCES post (id),
  PRIMARY KEY (category_id,post_id)
);


CREATE TABLE tag (
  id serial UNIQUE,
  name varchar(255) DEFAULT NULL,
  slug varchar(255) DEFAULT NULL
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
  type varchar(255) NOT NULL DEFAULT 'HTML' REFERENCES post_format (name),
  status comment_status DEFAULT 'pending',
  post_id integer NOT NULL REFERENCES post (id),
  uid integer NOT NULL REFERENCES users (id),
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
