-- MySQL dump 10.13  Distrib 5.5.50, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: PearlBee
-- ------------------------------------------------------
-- Server version	5.5.50-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET ucs2 NOT NULL,
  `slug` varchar(100) CHARACTER SET ucs2 NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `category_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Category table.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,'Uncategorized','uncategorized',1);
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comment`
--

DROP TABLE IF EXISTS `comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comment` (
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
  CONSTRAINT `comment_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`),
  CONSTRAINT `comment_ibfk_2` FOREIGN KEY (`uid`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COMMENT='Comment table.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comment`
--

LOCK TABLES `comment` WRITE;
/*!40000 ALTER TABLE `comment` DISABLE KEYS */;
INSERT INTO `comment` VALUES (1,'acesta e un comment','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-05-24 15:30:36','approved',2,1,NULL),(2,'replica','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-05-24 15:53:29','approved',2,1,NULL),(3,'drrdrd','foo','drd.trif@gmail.com','','http://www.gravatar.com/avatar/6c39cbb121b4ccccdb9ced7d926992c4','2016-07-16 16:05:07','pending',3,NULL,NULL),(4,'kllll','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-07-31 09:08:24','approved',3,1,NULL),(5,'test','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-07-31 09:19:19','approved',3,1,NULL),(6,'kkk','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-08-09 16:42:07','approved',3,1,NULL),(7,'l;;;','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-08-12 15:57:09','approved',2,1,NULL),(8,'kl;\'|\'sadaddaaddadadadadaadadaddadaaddaadd','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-08-12 15:57:31','approved',2,1,NULL),(9,'l;l','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-08-13 14:14:11','approved',3,1,4),(10,'qwert','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-08-15 15:07:30','approved',3,1,NULL),(11,'bghh','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-08-16 16:51:52','approved',3,1,NULL),(12,'opoos','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-08-16 16:53:15','approved',3,1,NULL),(13,'test','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-08-16 16:58:01','approved',3,1,5),(14,'super test','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-08-16 17:02:40','approved',3,1,NULL),(15,'hhhhhhhh','','','','http://www.gravatar.com/avatar/d41d8cd98f00b204e9800998ecf8427e','2016-08-17 16:30:54','approved',1,1,NULL);
/*!40000 ALTER TABLE `comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post`
--

DROP TABLE IF EXISTS `post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post` (
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='Post table.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post`
--

LOCK TABLES `post` WRITE;
/*!40000 ALTER TABLE `post` DISABLE KEYS */;
INSERT INTO `post` VALUES (1,'test','test-editare',NULL,'','<p>Acesta e un test</p>\r\n','2016-05-21 09:27:58','trash',1),(2,'new','new',NULL,'','<p>o noua postare edit</p>\r\n','2016-05-23 16:31:16','published',1),(3,'duper','duper',NULL,'','<p>superduper</p>\r\n','2016-07-14 15:52:31','published',1);
/*!40000 ALTER TABLE `post` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_category`
--

DROP TABLE IF EXISTS `post_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post_category` (
  `category_id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  PRIMARY KEY (`category_id`,`post_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `post_category_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`),
  CONSTRAINT `post_category_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Post category table.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_category`
--

LOCK TABLES `post_category` WRITE;
/*!40000 ALTER TABLE `post_category` DISABLE KEYS */;
INSERT INTO `post_category` VALUES (1,1),(1,2),(1,3);
/*!40000 ALTER TABLE `post_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_tag`
--

DROP TABLE IF EXISTS `post_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post_tag` (
  `tag_id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  PRIMARY KEY (`tag_id`,`post_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `post_tag_ibfk_1` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`),
  CONSTRAINT `post_tag_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Post tag table.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_tag`
--

LOCK TABLES `post_tag` WRITE;
/*!40000 ALTER TABLE `post_tag` DISABLE KEYS */;
/*!40000 ALTER TABLE `post_tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `settings` (
  `timezone` varchar(255) NOT NULL,
  `social_media` tinyint(1) NOT NULL DEFAULT '1',
  `theme_folder` varchar(255) NOT NULL,
  `blog_name` varchar(255) NOT NULL,
  `multiuser` tinyint(1) NOT NULL DEFAULT '0',
  `id` int(2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Settings table.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES ('Europe/Bucharest',1,'','/',0,1);
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tag`
--

DROP TABLE IF EXISTS `tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET ucs2 DEFAULT NULL,
  `slug` varchar(100) CHARACTER SET ucs2 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tag table.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tag`
--

LOCK TABLES `tag` WRITE;
/*!40000 ALTER TABLE `tag` DISABLE KEYS */;
/*!40000 ALTER TABLE `tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='User table.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'Default','Admin','admin','ddd8f33fbc8fd3ff70ea1d3768e7c5c151292d3a8c0972','2015-02-18 15:27:54','admin@admin.com',NULL,NULL,'admin',NULL,'activated','IQbmVFR+SEgTju9y+UzhwA=='),(2,'drd','drd','drd','7704f70a4ae4de38852e017f289b2c1c90ef84f2b44924','2016-05-21 07:18:37','mail@yahoo.com',NULL,NULL,'author',NULL,'deactivated','VykPghMJkSuf0k5aWIt1gA=='),(3,'bar','foo','barfoo','cffdf74a876b377b9855d517d36952025831299ec9b64b','2016-07-16 16:21:08','trif_dragos@yahoo.com',NULL,NULL,'author',NULL,'pending','epGqWQDmAhk0lvUmlz8WoA=='),(4,'gogo','gogo','gogo','5238124b643385e53bec3a71b696d39009ac4000286a1b','2016-08-17 16:09:58','gogo@yahoo.com',NULL,NULL,'author',NULL,'pending','UDGSDQQqCupZYgv8PRh1eA=='),(5,'gogol','gogol','gogol','a3dadfaf36b58dbf9efa06f126f253124d79284b1985c7','2016-08-17 16:29:51','gogol@yahoo.com',NULL,NULL,'author',NULL,'pending','iNZF7MBu4L5zQQ4CSlQq7A==');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-09-08 14:31:43
