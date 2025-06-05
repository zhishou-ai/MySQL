-- 创建数据库
CREATE DATABASE IF NOT EXISTS `zhishou_chat_app` 
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `zhishou_chat_app`;

-- 用户表
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(32) NOT NULL,
  `password_hash` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT 'default.jpg',
  `status` enum('online','offline','busy','invisible') DEFAULT 'offline',
  `last_active` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 好友关系表
CREATE TABLE IF NOT EXISTS `friends` (
  `relation_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user1_id` int unsigned NOT NULL,
  `user2_id` int unsigned NOT NULL,
  `relation_type` enum('friend','blocked') DEFAULT 'friend',
  `status` enum('pending','accepted','rejected') NOT NULL DEFAULT 'pending',
  `action_user_id` int unsigned COMMENT '发起操作的用户ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`relation_id`),
  UNIQUE KEY `unique_relationship` (`user1_id`,`user2_id`),
  KEY `user1_id` (`user1_id`),
  KEY `user2_id` (`user2_id`),
  CONSTRAINT `chk_user_order` CHECK (`user1_id` < `user2_id`),
  CONSTRAINT `fk_friends_user1` FOREIGN KEY (`user1_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_friends_user2` FOREIGN KEY (`user2_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 群组表
CREATE TABLE IF NOT EXISTS `groups` (
  `group_id` int unsigned NOT NULL AUTO_INCREMENT,
  `group_name` varchar(64) NOT NULL,
  `creator_id` int unsigned NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `announcement` text DEFAULT NULL,
  `avatar` varchar(255) DEFAULT 'group_default.jpg',
  `max_members` int unsigned DEFAULT 500,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`group_id`),
  KEY `creator_id` (`creator_id`),
  CONSTRAINT `fk_groups_creator` FOREIGN KEY (`creator_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 群组成员表
CREATE TABLE IF NOT EXISTS `group_members` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `group_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `role` enum('owner','admin','member') DEFAULT 'member',
  `is_muted` tinyint(1) NOT NULL DEFAULT 0,
  `joined_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_membership` (`group_id`,`user_id`),
  KEY `group_id` (`group_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fk_group_members_group` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_group_members_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 消息表
CREATE TABLE IF NOT EXISTS `messages` (
  `msg_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `sender_id` int unsigned NOT NULL,
  `receiver_type` enum('private','group') NOT NULL,
  `receiver_id` int unsigned NOT NULL,
  `content` text NOT NULL,
  `content_type` enum('text','image','file','video') DEFAULT 'text',
  `file_url` varchar(512) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `status` enum('sent','delivered','deleted') NOT NULL DEFAULT 'sent',
  `recalled_at` datetime DEFAULT NULL,
  `recalled_by` int unsigned DEFAULT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`msg_id`),
  KEY `sender_id` (`sender_id`),
  KEY `receiver_composite` (`receiver_type`,`receiver_id`),
  KEY `created_at` (`created_at`),
  CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 消息已读表
CREATE TABLE IF NOT EXISTS `message_reads` (
  `read_id` int unsigned NOT NULL AUTO_INCREMENT,
  `msg_id` bigint unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `read_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`read_id`),
  UNIQUE KEY `unique_read` (`msg_id`,`user_id`),
  KEY `msg_id` (`msg_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fk_message_reads_msg` FOREIGN KEY (`msg_id`) REFERENCES `messages` (`msg_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_message_reads_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 登录尝试记录表
CREATE TABLE IF NOT EXISTS `login_attempts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(32) NOT NULL,
  `attempt_count` int unsigned NOT NULL DEFAULT 0,
  `last_attempt` int NOT NULL COMMENT 'Unix时间戳',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE if NOT EXISTS `ip_id`(
  `ip` varchar(45) NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`ip`),
  CONSTRAINT `fk_ip_id_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- 创建数据库用户并授权
ALTER TABLE users ADD COLUMN `permission` ENUM('teacher', 'student') NOT NULL DEFAULT 'student' AFTER user_id;
CREATE USER IF NOT EXISTS 'chat_app'@'localhost' IDENTIFIED BY 'zhishou_chat';
GRANT ALL PRIVILEGES ON zhishou_chat_app.* TO 'chat_app'@'localhost';
FLUSH PRIVILEGES;