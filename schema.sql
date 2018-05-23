DROP TABLE IF EXISTS `resource`;
DROP TABLE IF EXISTS `resource_type`;
DROP TABLE IF EXISTS `user_extra_activity`;
DROP TABLE IF EXISTS `user_evaluation`;
DROP TABLE IF EXISTS `evaluation_answer`;
DROP TABLE IF EXISTS `evaluation_question`;
DROP TABLE IF EXISTS `evaluation`;
DROP TABLE IF EXISTS `extra_activity`;
DROP TABLE IF EXISTS `unit`;
DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `firstName` varchar(100) DEFAULT NULL,
  `lastName` varchar(100) DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_UN` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `unit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(100) NOT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `extra_activity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(100) NOT NULL,
  `points` int(11) NOT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `evaluation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unit_id` int(11) NOT NULL,
  `description` varchar(100) NOT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `evaluation_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `evaluation_id` int(11) NOT NULL,
  `question` varchar(100) NOT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `evaluation_question_evaluation_FK` (`evaluation_id`),
  CONSTRAINT `evaluation_question_evaluation_FK` FOREIGN KEY (`evaluation_id`) REFERENCES `evaluation` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `evaluation_answer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `evaluation_question_id` int(11) NOT NULL,
  `answer` varchar(100) NOT NULL,
  `correct` bit(1) NOT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `evaluation_answer_evaluation_question_FK` (`evaluation_question_id`),
  CONSTRAINT `evaluation_answer_evaluation_question_FK` FOREIGN KEY (`evaluation_question_id`) REFERENCES `evaluation_question` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_evaluation` (
  `user_id` int(11) NOT NULL,
  `evaluation_id` int(11) NOT NULL,
  `grade` int(11) NOT NULL,
  KEY `user_evaluation_user_FK` (`user_id`),
  KEY `user_evaluation_evaluation_FK` (`evaluation_id`),
  CONSTRAINT `user_evaluation_evaluation_FK` FOREIGN KEY (`evaluation_id`) REFERENCES `evaluation` (`id`),
  CONSTRAINT `user_evaluation_user_FK` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_extra_activity` (
  `user_id` int(11) NOT NULL,
  `extra_activity_id` int(11) NOT NULL,
  KEY `user_extra_activity_user_FK` (`user_id`),
  KEY `user_extra_activity_extra_activity_FK` (`extra_activity_id`),
  CONSTRAINT `user_extra_activity_extra_activity_FK` FOREIGN KEY (`extra_activity_id`) REFERENCES `extra_activity` (`id`),
  CONSTRAINT `user_extra_activity_user_FK` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `resource_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `resource` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_type_id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(100) NOT NULL,
  `url` varchar(100) NOT NULL,
  `order` int(11) NOT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `resource_resource_type_FK` (`resource_type_id`),
  KEY `resource_unit_FK` (`unit_id`),
  CONSTRAINT `resource_resource_type_FK` FOREIGN KEY (`resource_type_id`) REFERENCES `resource_type` (`id`),
  CONSTRAINT `resource_unit_FK` FOREIGN KEY (`unit_id`) REFERENCES `unit` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE OR REPLACE VIEW videos
AS
	SELECT a.id
	       , c.name AS unit
	       , a.`order`
	       , a.name
	       , a.description
	       , a.url
	       , a.createdAt
	       , a.updatedAt
	FROM   resource a
	       INNER JOIN resource_type b
	               ON b.id = a.resource_type_id
	       INNER JOIN unit c
	               ON c.id = a.unit_id
	WHERE  resource_type_id = 1;
	
	
INSERT INTO unadroid.users
(id, email, password, firstName, lastName, createdAt, updatedAt)
VALUES(1, 'pabloasalgado@gmail.com', 'pablo', 'Pablo ', 'Salgado ', '2018-05-20 23:10:53.000', '2018-05-20 23:10:53.000');

INSERT INTO unadroid.resource_type
(id, name, createdAt, updatedAt)
VALUES(1, 'Video', '2018-05-23 23:17:08.000', '2018-05-23 23:17:08.000');

INSERT INTO unadroid.resource_type
(id, name, createdAt, updatedAt)
VALUES(2, 'PDF', '2018-05-23 23:17:14.000', '2018-05-23 23:17:14.000');

INSERT INTO unadroid.unit
(id, name, description, createdAt, updatedAt)
VALUES(1, 'Unidad 1', 'Conceptos básicos', '2018-05-23 23:17:08.000', '2018-05-23 23:17:08.000');

INSERT INTO unadroid.resource
(id, resource_type_id, unit_id, name, description, url, `order`, createdAt, updatedAt)
VALUES(1, 1, 1, 'Java Primer', 'Copyright © 2012 – 2018, Dan Armendariz and David J. Malan of Harvard University', 'http://cs76.tv/2012/spring/lectures/2/lecture2.mp4', 1, '2018-05-23 23:17:09.000', '2018-05-23 23:17:12.000');

INSERT INTO unadroid.resource
(id, resource_type_id, unit_id, name, description, url, `order`, createdAt, updatedAt)
VALUES(2, 2, 1, 'Java Primer', 'Copyright © 2012 – 2018, Dan Armendariz and David J. Malan of Harvard University', 'http://cdn.cs76.net/2012/spring/lectures/2/lecture2-dan.pdf', 1, '2018-05-23 23:17:14.000', '2018-05-23 23:17:14.000');
