GRANT ALL PRIVILEGES ON PearlBee.* TO 'username'@'localhost' IDENTIFIED BY 'password';

DROP DATABASE IF EXISTS PearlBee;
CREATE DATABASE IF NOT EXISTS PearlBee;

USE PearlBee;

CREATE TABLE IF NOT EXISTS user (
	id 				INT NOT NULL AUTO_INCREMENT,
	first_name 		VARCHAR(255) NOT NULL,
	last_name 		VARCHAR(255) NOT NULL,
	username		VARCHAR(200) NOT NULL,
	password		VARCHAR(100) NOT NULL,
	register_date 	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	email			VARCHAR(255) NOT NULL,
	company 		VARCHAR(255),
	telephone 		VARCHAR(12),
	role 			ENUM('author', 'admin') NOT NULL DEFAULT 'author',
	activation_key  VARCHAR(100),
	status 			ENUM('deactivated', 'activated', 'suspended') NOT NULL DEFAULT 'deactivated',
	salt			CHAR(24) NOT NULL,
	PRIMARY KEY (id),
	UNIQUE KEY (username),
	UNIQUE KEY (email)
);

CREATE TABLE IF NOT EXISTS category (
	id  	INT NOT NULL AUTO_INCREMENT,
	name 	VARCHAR(100) NOT NULL,
	slug 	VARCHAR(100) NOT NULL,
	user_id INT NOT NULL,
	PRIMARY KEY (id),
	UNIQUE KEY (name),
	FOREIGN KEY (user_id) REFERENCES user(id)
);

CREATE TABLE IF NOT EXISTS post (
	id  			INT NOT NULL AUTO_INCREMENT,
	title 			VARCHAR(255) NOT NULL,
	slug 			VARCHAR(255) NOT NULL,
	description 	VARCHAR(255),
	cover 			VARCHAR(300) NOT NULL,
	content 		TEXT NOT NULL,
	created_date 	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	status 			ENUM('published', 'trash', 'draft') DEFAULT 'draft',
	user_id 		INT NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (user_id) REFERENCES user(id)
);

CREATE TABLE IF NOT EXISTS post_category (
	category_id INT NOT NULL,
	post_id 	INT NOT NULL,
	PRIMARY KEY (category_id, post_id),
	FOREIGN KEY (category_id) REFERENCES category(id),
	FOREIGN KEY (post_id) REFERENCES post(id)
);

CREATE TABLE IF NOT EXISTS tag (
	id  	INT NOT NULL AUTO_INCREMENT,
	name 	VARCHAR(100),
	slug 	varchar(100),
	PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS post_tag (
	tag_id  	INT NOT NULL,
	post_id 	INT NOT NULL,
	PRIMARY KEY (tag_id, post_id),
	FOREIGN KEY (tag_id) REFERENCES tag(id),
	FOREIGN KEY (post_id) REFERENCES post(id)
);

CREATE TABLE IF NOT EXISTS comment (
	id  			INT NOT NULL AUTO_INCREMENT,
	content 		TEXT,
	fullname 		VARCHAR(100),
	email 			VARCHAR(200),
	website 		VARCHAR(255),
	avatar 			VARCHAR(255),
	comment_date 	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	status 			ENUM('approved', 'spam', 'pending', 'trash') DEFAULT 'pending',
	post_id 		INT NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (post_id) REFERENCES post(id)
);

CREATE TABLE IF NOT EXISTS settings (
	timezone 		VARCHAR(255) NOT NULL,
	social_media 	BOOLEAN NOT NULL DEFAULT '1',
	blog_path		VARCHAR(255) NOT NULL DEFAULT '/',
	PRIMARY KEY (timezone, social_media, blog_path)
);

-- default login: 	   	admin
-- default password: 	password

insert into user (first_name, last_name, username, password, email, status, role, salt) 
	values ("Default", "Admin", "admin", "ddd8f33fbc8fd3ff70ea1d3768e7c5c151292d3a8c0972", 
			"you@domain.cow", "activated", "admin", "IQbmVFR+SEgTju9y+UzhwA==");
	
insert into category (name, slug, user_id) values ("Uncategorized", "uncategorized", 1);

insert into settings ( timezone, social_media, blog_path ) values ( 'Europe/Bucharest', 1, '/' );
