DROP DATABASE IF EXISTS PearlBee;
CREATE DATABASE IF NOT EXISTS PearlBee;

USE PearlBee;

CREATE TABLE IF NOT EXISTS user (
	id 				INT NOT NULL AUTO_INCREMENT,
	first_name 		VARCHAR(300) NOT NULL,
	last_name 		VARCHAR(300) NOT NULL,
	username		VARCHAR(200) NOT NULL,
	password		VARCHAR(100) NOT NULL,
	register_date 	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	email			VARCHAR(300) NOT NULL,
	company 		VARCHAR(300),
	telephone 		VARCHAR(12),
	role 			ENUM('author', 'admin') NOT NULL DEFAULT 'author',
	activation_key  VARCHAR(100),
	status 			ENUM('deactivated', 'activated', 'suspended') NOT NULL DEFAULT 'deactivated',
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
	title 			VARCHAR(200) NOT NULL,
	description 	VARCHAR(200),
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
	user_id 	INT NOT NULL,
	timezone 	varchar(200) NOT NULL,
	PRIMARY KEY ( user_id ),
	FOREIGN KEY ( user_id ) REFERENCES user(id)
);

insert into user (first_name, last_name, username, password, email, status, role) values ("Andrei", "Cacio", "admin", "3ae52f9bffc2909cf5ea8342c244c12416e397ca", "andrei.cacio@yahoo.com", "activated", "admin");
insert into category (name, slug, user_id) values ("Uncategorized", "uncategorized", 1);


