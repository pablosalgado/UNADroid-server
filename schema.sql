USE unadroid;

DROP TABLE IF EXISTS `resource`;
DROP TABLE IF EXISTS `resource_type`;
DROP TABLE IF EXISTS `user_extra_activity`;
DROP TABLE IF EXISTS `user_evaluation`;
DROP TABLE IF EXISTS `evaluation_answer`;
DROP TABLE IF EXISTS `evaluation_question`;
DROP TABLE IF EXISTS `evaluation`;
DROP TABLE IF EXISTS `extra_activity`;
DROP TABLE IF EXISTS `units`;
DROP TABLE IF EXISTS `users`;


-- ****************************************************************************
-- Tablas
-- ****************************************************************************
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

CREATE TABLE `units` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `order` int(11) NOT NULL,
  `description` varchar(100) NOT NULL,
  `iconName`varchar(100) NOT NULL DEFAULT "iconName",
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
  `description` text NOT NULL,
  `url` varchar(100) NOT NULL,
  `order` int(11) NOT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `resource_resource_type_FK` (`resource_type_id`),
  KEY `resource_unit_FK` (`unit_id`),
  CONSTRAINT `resource_resource_type_FK` FOREIGN KEY (`resource_type_id`) REFERENCES `resource_type` (`id`),
  CONSTRAINT `resource_unit_FK` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ****************************************************************************
-- VISTAS
-- ****************************************************************************
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
	       INNER JOIN units c
	               ON c.id = a.unit_id
	WHERE  resource_type_id = 1
	ORDER BY
	       c.order
	       , a.order;
	
INSERT INTO unadroid.users
(id, email, password, firstName, lastName, createdAt, updatedAt)
VALUES(1, 'pabloasalgado@gmail.com', 'pablo', 'Pablo ', 'Salgado ', '2018-05-20 23:10:53.000', '2018-05-20 23:10:53.000');
INSERT INTO unadroid.users
(id, email, password, firstName, lastName, createdAt, updatedAt)
VALUES(2, 'jsebascalle@gmail.com', '123456789', 'Juan', 'Calle', '2018-05-24 02:58:35.000', '2018-05-24 02:58:35.000');
INSERT INTO unadroid.users
(id, email, password, firstName, lastName, createdAt, updatedAt)
VALUES(3, 'unad@edu.co', '12345', 'Unad', 'Droid', '2018-06-10 01:39:16.000', '2018-06-10 01:39:16.000');

-- ****************************************************************************
-- TIPO DE RECURSO
-- ****************************************************************************
INSERT INTO unadroid.resource_type
(id, name, createdAt, updatedAt)
VALUES(1, 'Video', '2018-05-23 23:17:08.000', '2018-05-23 23:17:08.000');

INSERT INTO unadroid.resource_type
(id, name, createdAt, updatedAt)
VALUES(2, 'PDF', '2018-05-23 23:17:14.000', '2018-05-23 23:17:14.000');

-- ****************************************************************************
-- UNIDADES
-- ****************************************************************************
INSERT INTO unadroid.units
            (id
             , name
             , description
             , `order`             
             , createdat
             , updatedat)
VALUES     (1
            , 'Unidad 1'
            , 'Conceptos básicos'
            , 1
            , NOW()
            , NOW());

INSERT INTO unadroid.units
            (id
             , name
             , description
             , `order`
             , createdat
             , updatedat)
VALUES     (2
            , 'Unidad 2'
            , 'SDK, Activities and Views'
            , 2
            , NOW()
            , NOW());

INSERT INTO unadroid.units
            (id
             , name
             , description
             , `order`
             , createdat
             , updatedat)
VALUES     (3
            , 'Unidad 3'
            , 'Resources, Assets and Intents'
            , 3
            , NOW()
            , NOW());  
           
-- ****************************************************************************
-- VIDEOS
-- ****************************************************************************

-- UNIDAD 1
INSERT INTO unadroid.resource
            (resource_type_id
             , unit_id
             , name
             , description
             , url
             , `order`
             , createdat
             , updatedat)
VALUES     (1
            , 1
            , 'Android and Android Studio: Getting Started.'
            , 'Getting Started with Android Development using Android Studio.'
            , 'Z98hXV9GmzY'
            , 1
            , NOW()
            , NOW());  

INSERT INTO unadroid.resource
            (resource_type_id
             , unit_id
             , name
             , description
             , url
             , `order`
             , createdat
             , updatedat)
VALUES     (1
            , 1
            , 'Android Studio For Beginners Part 1.'
            , 'Begginer Tutorial Part 1.'
            , 'dFlPARW5IX8'
            , 2
            , NOW()
            , NOW());
           
INSERT INTO unadroid.resource
            (resource_type_id
             , unit_id
             , name
             , description
             , url
             , `order`
             , createdat
             , updatedat)
VALUES     (1
            , 1
            , 'Android Studio For Beginners Part 2.'
            , 'Launching multiple activities in Android Studio.'
            , '6ow3L39Wxmg'
            , 3
            , NOW()
            , NOW());  

-- UNIDAD 2
INSERT INTO unadroid.resource
            (resource_type_id
             , unit_id
             , name
             , description
             , url
             , `order`
             , createdat
             , updatedat)
VALUES     (1
            , 2
            , 'Understanding activity states in Android Studio.'
            , 'Basic understanding of Android activities.'
            , 'S8voQap6suk'
            , 1
            , NOW()
            , NOW());  

INSERT INTO unadroid.resource
            (resource_type_id
             , unit_id
             , name
             , description
             , url
             , `order`
             , createdat
             , updatedat)
VALUES     (1
            , 2
            , 'How to build user interface using Android Studio part 1.'
            , 'Building the user interface of Android app.'
            , 'zgzVCBZyTkc'
            , 2
            , NOW()
            , NOW());  
           
INSERT INTO unadroid.resource
            (resource_type_id
             , unit_id
             , name
             , description
             , url
             , `order`
             , createdat
             , updatedat)
VALUES     (1
            , 2
            , 'How to build user interface using Android Studio part 2.'
            , 'Building the user interface of Android app.'
            , 'Kpyf6s-vPxg'
            , 3
            , NOW()
            , NOW());  

--
-- DOCUMENTOS
INSERT INTO unadroid.resource
(resource_type_id, unit_id, name, description, url, `order`, createdAt, updatedAt)
VALUES(2, 1, 'Java Primer', 'Copyright © 2012 – 2018, Dan Armendariz and David J. Malan of Harvard University', 'http://cdn.cs76.net/2012/spring/lectures/2/lecture2-dan.pdf', 1, '2018-05-23 23:17:14.000', '2018-05-23 23:17:14.000');
