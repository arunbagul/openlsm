-- MySQL dump 10.13  Distrib 5.1.41, for debian-linux-gnu (i486)
--
-- Host: localhost    Database: world_mon
-- ------------------------------------------------------
-- Server version	5.1.41-3ubuntu12.3

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
-- Table structure for table `file_list`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `file_list` (
  `group_name` varchar(30) NOT NULL,
  `file_path` varchar(200) NOT NULL DEFAULT '',
  `uid` varchar(15) DEFAULT NULL,
  `gid` varchar(15) DEFAULT NULL,
  `permission` int(11) DEFAULT NULL,
  `ctime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `mtime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `svn_resvision_no` int(11) DEFAULT NULL,
  `action_on_update` varchar(100) DEFAULT NULL,
  `status` enum('Enabled','Disabled') DEFAULT NULL,
  PRIMARY KEY (`group_name`,`file_path`),
  CONSTRAINT `file_list_ibfk_1` FOREIGN KEY (`group_name`) REFERENCES `group_details` (`group_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_details`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_details` (
  `group_name` varchar(30) NOT NULL,
  `description` varchar(200) NOT NULL,
  `dept` varchar(20) DEFAULT 'myops',
  `svn_resvision_no` int(11) DEFAULT NULL,
  `status` enum('Enabled','Disabled') NOT NULL DEFAULT 'Disabled',
  PRIMARY KEY (`group_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `host_details`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `host_details` (
  `host_name` varchar(40) NOT NULL,
  `description` varchar(200) NOT NULL,
  `host_ipaddr` varchar(40) NOT NULL,
  `primary_group` varchar(30) DEFAULT NULL,
  `secondary_group_list` varchar(200) DEFAULT NULL,
  `host_status` enum('up','down','ofr') DEFAULT NULL,
  `host_category` enum('Production','QA','Testing') DEFAULT NULL,
  `centconf_status` enum('Enabled','Disabled') NOT NULL DEFAULT 'Disabled',
  PRIMARY KEY (`host_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `host_log`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `host_log` (
  `host_name` varchar(40) NOT NULL,
  `last_run_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_run_status` enum('Running','Failed','Successful','Unknown') DEFAULT NULL,
  `log_messagge` longtext,
  PRIMARY KEY (`host_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_department`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_department` (
  `dept_name` varchar(50) NOT NULL,
  `dept_desc` varchar(50) DEFAULT NULL,
  `status` enum('Enabled','Disabled') NOT NULL,
  PRIMARY KEY (`dept_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `user_id` varchar(50) NOT NULL,
  `name` varchar(250) NOT NULL,
  `password` varchar(50) NOT NULL,
  `dept_name` varchar(255) NOT NULL,
  `status` enum('Enabled','Disabled') NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2010-07-05 19:01:19
