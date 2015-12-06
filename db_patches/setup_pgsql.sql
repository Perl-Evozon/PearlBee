CREATE TYPE user_status AS ENUM (
    'deactivated',
    'activated',
    'suspended',
    'pending'
);

CREATE TYPE user_roles AS ENUM (
    'author',
    'admin'
);

CREATE TYPE post_status AS ENUM (
    'published',
    'trash',
    'draft'
);

CREATE TYPE comment_status AS ENUM (
    'approved',
    'spam',
    'pending',
    'trash'
);

CREATE TABLE IF NOT EXISTS users (
    id SERIAL NOT NULL PRIMARY KEY,
    first_name varchar(255) NOT NULL,
    last_name varchar(255) NOT NULL,
    username varchar(200) NOT NULL,
    password varchar(100) NOT NULL,
    register_date timestamp NOT NULL DEFAULT now(),
    email varchar(255) NOT NULL,
    company varchar(255) DEFAULT NULL,
    telephone varchar(12) DEFAULT NULL,
    role user_roles NOT NULL DEFAULT 'author',
    activation_key varchar(100) DEFAULT NULL,
    status user_status NOT NULL DEFAULT 'deactivated',
    salt char(24) NOT NULL,
    UNIQUE ( username ),
    UNIQUE ( email )
);

CREATE TABLE IF NOT EXISTS category (
    id SERIAL NOT NULL PRIMARY KEY,
    name varchar(100) NOT NULL,
    slug varchar(100) NOT NULL,
    user_id integer NOT NULL,
    UNIQUE ( name ),
    CONSTRAINT category_ibfk_1 FOREIGN KEY (user_id) REFERENCES users (id)
);
CREATE INDEX category_idx1 ON category( user_id );

CREATE TABLE IF NOT EXISTS post (
    id SERIAL NOT NULL PRIMARY KEY,
    title varchar(255) NOT NULL,
    slug varchar(255) NOT NULL,
    description varchar(255) DEFAULT NULL,
    cover varchar(300) NOT NULL,
    content text NOT NULL,
    created_date timestamp NOT NULL DEFAULT now(),
    status post_status NOT NULL DEFAULT 'draft',
    user_id integer NOT NULL,
    CONSTRAINT post_ibfk_1 FOREIGN KEY (user_id) REFERENCES users (id)
);
CREATE INDEX post_idx1 ON post( user_id );

CREATE TABLE IF NOT EXISTS post_category (
    category_id integer NOT NULL,
    post_id integer NOT NULL,
    PRIMARY KEY (category_id,post_id),
    CONSTRAINT post_category_ibfk_1 FOREIGN KEY (category_id) REFERENCES category (id),
    CONSTRAINT post_category_ibfk_2 FOREIGN KEY (post_id) REFERENCES post (id)
);
CREATE INDEX post_category_idx1 ON post_category( post_id );

CREATE TABLE IF NOT EXISTS tag (
    id SERIAL NOT NULL PRIMARY KEY,
    name varchar(100) DEFAULT NULL,
    slug varchar(100) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS post_tag (
    tag_id integer NOT NULL,
    post_id integer NOT NULL,
    PRIMARY KEY (tag_id,post_id),
    CONSTRAINT post_tag_ibfk_1 FOREIGN KEY (tag_id) REFERENCES tag (id),
    CONSTRAINT post_tag_ibfk_2 FOREIGN KEY (post_id) REFERENCES post (id)
);
CREATE INDEX post_tag_idx1 ON post_tag( post_id );

CREATE TABLE IF NOT EXISTS comment (
  id SERIAL NOT NULL PRIMARY KEY,
  content text,
  fullname varchar(100) DEFAULT NULL,
  email varchar(200) DEFAULT NULL,
  website varchar(255) DEFAULT NULL,
  avatar varchar(255) DEFAULT NULL,
  comment_date timestamp NOT NULL DEFAULT now(),
  status comment_status DEFAULT 'pending',
  post_id integer NOT NULL,
  uid integer DEFAULT NULL,
  reply_to integer DEFAULT NULL,
  CONSTRAINT comment_ibfk_2 FOREIGN KEY (uid) REFERENCES users (id),
  CONSTRAINT comment_ibfk_1 FOREIGN KEY (post_id) REFERENCES post (id)
);
CREATE INDEX comment_idx1 ON comment( post_id );
CREATE INDEX comment_idx2 ON comment( reply_to );
CREATE INDEX comment_idx3 ON comment( uid );

CREATE TABLE IF NOT EXISTS settings (
  timezone varchar(255) NOT NULL,
  social_media integer NOT NULL DEFAULT '1',
  blog_path varchar(255) NOT NULL DEFAULT '/',
  theme_folder varchar(255) NOT NULL,
  blog_name varchar(255) NOT NULL,
  multiuser integer NOT NULL DEFAULT '0',
  id SERIAL NOT NULL PRIMARY KEY
);

-- Override sum() to make some of our views work as intended
-- See http://stackoverflow.com/questions/20281125/why-aggregate-functions-in-postgresql-do-not-work-with-boolean-data-type/20283487#20283487
create or replace function bool_add (bigint, boolean)
    returns bigint as
$body$
    select $1 + case when true then 1 else 0 end;
$body$ language sql;

create aggregate sum(boolean) (
    sfunc=bool_add,
    stype=int8,
    initcond='0'
);

-- default admin login user : admin
-- default admin login pass : password
INSERT INTO users VALUES (1,'Default','Admin','admin','ddd8f33fbc8fd3ff70ea1d3768e7c5c151292d3a8c0972','2015-02-18 15:27:54','admin@admin.com',NULL,NULL,'admin',NULL,'activated','IQbmVFR+SEgTju9y+UzhwA==');
	
INSERT INTO category VALUES (1,'Uncategorized','uncategorized',1);

INSERT INTO settings VALUES ('Europe/Bucharest',1,'','/','PearlBee',1,0);

