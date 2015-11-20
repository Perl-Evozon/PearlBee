GRANT ALL PRIVILEGES ON BlogsPerlOrg.* TO 'username'@'localhost' IDENTIFIED BY 'password';

DROP DATABASE IF EXISTS BlogsPerlOrg;
CREATE DATABASE IF NOT EXISTS BlogsPerlOrg;

USE BlogsPerlOrg;


--
-- Users can have their type chosen from this list.
-- The unique constraint on names means the names are effectively their own ID.
--
CREATE TABLE IF NOT EXISTS `user_type` (
  `name` varchar(255) CHARACTER SET ucs2 NOT NULL,
  PRIMARY KEY (`name`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='List of user types.';

INSERT INTO `user_type` VALUES('superuser'),
                              ('user'),
                              ('visitor');


--
-- Users now are assigned to a class when they're created.
--
CREATE TABLE IF NOT EXISTS `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) CHARACTER SET ucs2 NOT NULL,
  `last_name` varchar(255) CHARACTER SET ucs2 NOT NULL,
  `type` varchar(255) CHARACTER SET ucs2 NOT NULL,
  `username` varchar(200) NOT NULL,
  `password` varchar(100) NOT NULL,
  `register_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `email` varchar(255) NOT NULL,
  `company` varchar(255) DEFAULT NULL,
  `telephone` varchar(12) DEFAULT NULL,
  `role` enum('author','admin') NOT NULL DEFAULT 'author',
  `activation_key` varchar(100) DEFAULT NULL,
  `status` enum('deactivated','activated','suspended','pending') NOT NULL DEFAULT 'deactivated',
  `salt` char(24) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`type`) REFERENCES `user_type` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='User information.';


--
-- User types have a set of abilities chosen from this list.
-- The unique constraint on names means the names are effectively their own ID.
--
CREATE TABLE IF NOT EXISTS `ability` (
  `name` varchar(255) CHARACTER SET ucs2 NOT NULL,
  PRIMARY KEY (`name`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='List of user abilities.';

INSERT INTO `ability`
       VALUES('create user'),('view user'),('update user'),('delete user'),
             ('create blog'),('view blog'),('update blog'),('delete blog'),
             ('create post'),('view post'),('update post'),('delete post');


--
-- Access controls for a given user type
--
CREATE TABLE IF NOT EXISTS `acl` (
  `name` varchar(255) CHARACTER SET ucs2 NOT NULL,
  `ability` varchar(255) CHARACTER SET ucs2 NOT NULL,
--  PRIMARY KEY (`name`,`ability`)
  PRIMARY KEY (`name`,`ability`),
  CONSTRAINT `acl_ibfk_1` FOREIGN KEY (`name`) REFERENCES `user_type` (`name`),
  CONSTRAINT `acl_ibfk_2` FOREIGN KEY (`ability`) REFERENCES `ability` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='Access control lists.';

INSERT INTO `acl` VALUES('superuser','create user'),
                        ('superuser','view user'),
                        ('superuser','delete user'),
                        ('user',     'create post'),
                        ('user',     'view post'),
                        ('user',     'delete post'),
                        ('visitor',  'view post');



CREATE TABLE IF NOT EXISTS `blog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET ucs2 NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `edited_date` timestamp,
  `status` enum('deactivated','activated','suspended','pending') NOT NULL DEFAULT 'deactivated',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='Blog information.';


CREATE TABLE IF NOT EXISTS `blog_owners` (
  `user_id` int(11) NOT NULL,
  `blog_id` int(11) NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('deactivated','activated','suspended','pending') NOT NULL DEFAULT 'deactivated',
  PRIMARY KEY (`user_id`,`blog_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='Blog owners.';


CREATE TABLE IF NOT EXISTS `category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET ucs2 NOT NULL,
  `slug` varchar(100) CHARACTER SET ucs2 NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `category_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='Category table.';


CREATE TABLE IF NOT EXISTS `post` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET ucs2 NOT NULL,
  `slug` varchar(255) CHARACTER SET ucs2 NOT NULL,
  `description` varchar(255) CHARACTER SET ucs2 DEFAULT NULL,
  `cover` varchar(300) NOT NULL,
  `content` text CHARACTER SET ucs2 NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `type` enum('HTML','Markdown') DEFAULT 'HTML',
  `status` enum('published','trash','draft') DEFAULT 'draft',
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `post_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='Post table.';


CREATE TABLE IF NOT EXISTS `post_category` (
  `category_id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  PRIMARY KEY (`category_id`,`post_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `post_category_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`),
  CONSTRAINT `post_category_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Post category table.';


CREATE TABLE IF NOT EXISTS `tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET ucs2 DEFAULT NULL,
  `slug` varchar(100) CHARACTER SET ucs2 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='Tag table.';


CREATE TABLE IF NOT EXISTS `post_tag` (
  `tag_id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  PRIMARY KEY (`tag_id`,`post_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `post_tag_ibfk_1` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`),
  CONSTRAINT `post_tag_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Post tag table.';


CREATE TABLE IF NOT EXISTS `comment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` text CHARACTER SET ucs2,
  `fullname` varchar(100) CHARACTER SET ucs2 DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `comment_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `type` enum('HTML','Markdown') DEFAULT 'HTML',
  `status` enum('approved','spam','pending','trash') DEFAULT 'pending',
  `post_id` int(11) NOT NULL,
  `uid` int(11) DEFAULT NULL,
  `reply_to` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  KEY `fk_comment_reply_to` (`reply_to`),
  KEY `comment_ibfk_2` (`uid`),
  CONSTRAINT `comment_ibfk_2` FOREIGN KEY (`uid`) REFERENCES `user` (`id`),
  CONSTRAINT `comment_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='Comment table.';


CREATE TABLE IF NOT EXISTS `settings` (
  `timezone` varchar(255) NOT NULL,
  `social_media` tinyint(1) NOT NULL DEFAULT '1',
  `blog_path` varchar(255) NOT NULL DEFAULT '/',
  `theme_folder` varchar(255) NOT NULL,
  `blog_name` varchar(255) NOT NULL,
  `multiuser` tinyint(1) NOT NULL DEFAULT '0',
  `id` int(2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Settings table.';

-- default admin login user : admin
-- default admin login pass : password
INSERT INTO `user` VALUES (1,'Default','Admin','superuser','admin','ddd8f33fbc8fd3ff70ea1d3768e7c5c151292d3a8c0972','2015-02-18 15:27:54','admin@admin.com',NULL,NULL,'admin',NULL,'activated','IQbmVFR+SEgTju9y+UzhwA==');
	
INSERT INTO `category` VALUES (1,'Uncategorized','uncategorized',1);

INSERT INTO `settings` VALUES ('Europe/Bucharest',1,'','/','BlogsPerlOrg',1,0);
