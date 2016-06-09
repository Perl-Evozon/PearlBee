-- GRANT ALL PRIVILEGES ON PearlBee.* TO 'username'@'localhost' IDENTIFIED BY 'password';

-- DROP DATABASE IF EXISTS PearlBee;
-- CREATE DATABASE IF NOT EXISTS PearlBee;

-- USE PearlBee;

CREATE TYPE role_type as enum('author','admin');
CREATE TYPE status_type as enum('deactivated','activated','suspended','pending');
CREATE TABLE "user" (
  id serial UNIQUE,
  first_name varchar(255) NOT NULL,
  last_name varchar(255) NOT NULL,
  username varchar(200) NOT NULL UNIQUE,
  password varchar(128) NOT NULL,
  register_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  email varchar(255) NOT NULL UNIQUE,
  company varchar(255) DEFAULT NULL,
  telephone varchar(12) DEFAULT NULL,
  role role_type NOT NULL DEFAULT 'author',
  activation_key varchar(100) DEFAULT NULL,
  status status_type NOT NULL DEFAULT 'deactivated'
);


CREATE TABLE category (
  id serial UNIQUE, 
  name varchar(100) NOT NULL UNIQUE,
  slug varchar(100) NOT NULL,
  user_id integer NOT NULL REFERENCES "user" (id)
);


CREATE TYPE status_post_type as enum('published','trash','draft');
CREATE TABLE post (
  id serial UNIQUE,
  title varchar(255) NOT NULL,
  slug varchar(255) NOT NULL,
  description varchar(255) DEFAULT NULL,
  cover varchar(300) NOT NULL,
  content text NOT NULL,
  created_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status status_post_type DEFAULT 'draft',
  user_id integer NOT NULL REFERENCES "user" (id)
);


CREATE TABLE post_category (
  category_id integer NOT NULL REFERENCES category (id),
  post_id integer NOT NULL REFERENCES post (id)
);


CREATE TABLE tag (
  id serial UNIQUE,
  name varchar(100) DEFAULT NULL,
  slug varchar(100) DEFAULT NULL
);


CREATE TABLE post_tag (
  tag_id integer NOT NULL REFERENCES tag (id),
  post_id integer NOT NULL REFERENCES post (id)
);


CREATE TYPE status_comment_type as enum('approved','spam','pending','trash');
CREATE TABLE comment (
  id serial UNIQUE,
  content text,
  fullname varchar(100) DEFAULT NULL,
  email varchar(200) DEFAULT NULL,
  website varchar(255) DEFAULT NULL,
  avatar varchar(255) DEFAULT NULL,
  comment_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status status_comment_type DEFAULT 'pending',
  post_id integer NOT NULL REFERENCES post (id),
  uid integer DEFAULT NULL REFERENCES "user" (id),
  reply_to integer DEFAULT NULL
);


CREATE TABLE settings (
  timezone varchar(255) NOT NULL,
  social_media integer NOT NULL DEFAULT '1',
  theme_folder varchar(255) NOT NULL,
  blog_name varchar(255) NOT NULL,
  multiuser integer NOT NULL DEFAULT '0',
  id serial UNIQUE
);

-- default admin login user : admin
-- default admin login pass : password
INSERT INTO "user" VALUES (1,'Default','Admin','admin','$6$NWyNhiU0s77MA8WA$0JtxuBt1ObAwl8FWxKnQH8SzCh6g5oaRAWTGF9OZiUfjFWxNBCi2B3JDuop0au9dsLe0lQpqHk9h55t6KEMc7.','2015-02-18 15:27:54','admin@admin.com',NULL,NULL,'admin',NULL,'activated','IQbmVFR+SEgTju9y+UzhwA==');
	
INSERT INTO category VALUES (1,'Uncategorized','uncategorized',1);

INSERT INTO settings VALUES ('Europe/Bucharest',1,'/','PearlBee',1,0);
