

--
-- Users can have their type chosen from this list.
-- The unique constraint on names means the names are effectively their own ID.
--
CREATE TABLE IF NOT EXISTS `role` (
  `name` varchar(255) CHARACTER SET ucs2 NOT NULL,
  PRIMARY KEY (`name`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='List of user types.';


--
-- Users now are assigned to a class when they're created.
--
CREATE TABLE IF NOT EXISTS `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET ucs2 NOT NULL,
  `username` varchar(200) NOT NULL,
  `password` varchar(128) NOT NULL,
  `preferred_language` varchar(50) DEFAULT NULL,
  `register_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `email` varchar(255), -- Weakening
  `avatar_path` varchar(255) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `telephone` varchar(12) DEFAULT NULL,
  `role` varchar(255) CHARACTER SET ucs2 NOT NULL DEFAULT 'author',
  `activation_key` varchar(100) DEFAULT NULL,
  `status` enum('active', 'inactive', 'suspended') NOT NULL default 'inactive',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`role`) REFERENCES `role` (`name`)
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


--
-- Access controls for a given user type
--
CREATE TABLE IF NOT EXISTS `acl` (
  `name` varchar(255) CHARACTER SET ucs2 NOT NULL,
  `ability` varchar(255) CHARACTER SET ucs2 NOT NULL,
  PRIMARY KEY (`name`,`ability`),
  CONSTRAINT `acl_ibfk_1` FOREIGN KEY (`name`) REFERENCES `role` (`name`),
  CONSTRAINT `acl_ibfk_2` FOREIGN KEY (`ability`) REFERENCES `ability` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='Access control lists.';


CREATE TABLE IF NOT EXISTS `blog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(512) CHARACTER SET ucs2 NOT NULL,
  `description` varchar(512) CHARACTER SET ucs2,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `edited_date` timestamp,
  `status` enum('inactive','active','suspended','pending') NOT NULL DEFAULT 'inactive',
  `email_notification` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='Blog information.';


CREATE TABLE IF NOT EXISTS `blog_owners` (
  `user_id` int(11) NOT NULL,
  `blog_id` int(11) NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('inactive','active','suspended','pending') NOT NULL DEFAULT 'inactive',
  PRIMARY KEY (`user_id`,`blog_id`),
  CONSTRAINT `blog_owner_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `blog_owner_ibfk_2` FOREIGN KEY (`blog_id`) REFERENCES `blog` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='Blog owners.';


CREATE TABLE IF NOT EXISTS `category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET ucs2 NOT NULL,
  `slug` varchar(100) CHARACTER SET ucs2 NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `category_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='Category table.';


CREATE TABLE IF NOT EXISTS `post` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET ucs2 NOT NULL,
  `slug` varchar(255) CHARACTER SET ucs2,
  `description` varchar(255) CHARACTER SET ucs2 DEFAULT NULL,
  `cover` varchar(300),
  `content` text CHARACTER SET ucs2 NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `type` enum('HTML','Markdown') DEFAULT 'HTML',
  `status` enum('published','trash','draft') DEFAULT 'draft',
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `post_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='Post table.';


CREATE TABLE IF NOT EXISTS `asset` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `blog_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `file_ext` varchar(20) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),

  CONSTRAINT `asset_ibfk_1` FOREIGN KEY (`blog_id`) REFERENCES `blog` (`id`),
  CONSTRAINT `asset_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Asset table.';


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
  `name` varchar(255) CHARACTER SET ucs2 DEFAULT NULL,
  `slug` varchar(255) CHARACTER SET ucs2 DEFAULT NULL,
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
