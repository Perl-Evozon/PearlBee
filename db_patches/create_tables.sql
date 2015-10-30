GRANT ALL PRIVILEGES ON PearlBee.* TO 'username'@'localhost' IDENTIFIED BY 'password';

DROP DATABASE IF EXISTS PearlBee;
CREATE DATABASE IF NOT EXISTS PearlBee;

USE PearlBee;

CREATE TABLE IF NOT EXISTS `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) CHARACTER SET ucs2 NOT NULL,
  `last_name` varchar(255) CHARACTER SET ucs2 NOT NULL,
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
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='User table.';


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

CREATE TABLE IF NOT EXISTS `post_meta` (
  `post_id` int(11) NOT NULL,
  `meta_key` varchar(50) NOT NULL,
  `meta_value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`post_id`, `meta_key`),
  CONSTRAINT `post_id_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `post` ( `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Post metadata table.';

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
INSERT INTO `user` VALUES (1,'Default','Admin','admin','ddd8f33fbc8fd3ff70ea1d3768e7c5c151292d3a8c0972','2015-02-18 15:27:54','admin@admin.com',NULL,NULL,'admin',NULL,'activated','IQbmVFR+SEgTju9y+UzhwA==');
	
INSERT INTO `category` VALUES (1,'Uncategorized','uncategorized',1);

INSERT INTO `settings` VALUES ('Europe/Bucharest',1,'','/','PearlBee',1,0);
