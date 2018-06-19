USE unadroid;

DROP TABLE IF EXISTS `resources`;
DROP TABLE IF EXISTS `resource_type`;
DROP TABLE IF EXISTS `user_extra_activity`;
DROP TABLE IF EXISTS `user_evaluation`;
DROP TABLE IF EXISTS `evaluation_answer`;
DROP TABLE IF EXISTS `evaluation_question`;
DROP TABLE IF EXISTS `question_type`;
DROP TABLE IF EXISTS `evaluations`;
DROP TABLE IF EXISTS `extra_activity`;
DROP TABLE IF EXISTS `topics`;
DROP TABLE IF EXISTS `units`;
DROP TABLE IF EXISTS `users`;

-- ****************************************************************************
-- Tablas
-- ****************************************************************************
CREATE TABLE `users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(100) NOT NULL,
  `password` VARCHAR(100) NOT NULL,
  `firstName` VARCHAR(100) NULL DEFAULT NULL,
  `lastName` VARCHAR(100) NULL DEFAULT NULL,
  `createdAt` DATETIME NULL DEFAULT NULL,
  `updatedAt` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `users_UN` (`email`)
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

CREATE TABLE `topics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `description` text,
  `order` int(11) DEFAULT NULL,
  `unit_id` int(11) DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `topics_units_FK` (`unit_id`),
  CONSTRAINT `topics_units_FK` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`)
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

CREATE TABLE `evaluations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unit_id` int(11) NOT NULL,
  `name`varchar(50) NOT NULL,
  `description` varchar(100) NOT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `question_type` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `description` varchar(50) NOT NULL DEFAULT 'Pregunta generica',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Contiene los tipos de preguntas que se le pueden hacer al usuario.';

CREATE TABLE `evaluation_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `evaluation_id` int(11) NOT NULL,
  `question_type_id` int(11) unsigned NOT NULL DEFAULT '1',
  `question` varchar(100) NOT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `evaluation_question_evaluation_FK` (`evaluation_id`),
  KEY `question_type_id_FK` (`question_type_id`),
  CONSTRAINT `evaluation_question_evaluation_FK` FOREIGN KEY (`evaluation_id`) REFERENCES `evaluations` (`id`),
  CONSTRAINT `question_type_id_FK` FOREIGN KEY (`question_type_id`) REFERENCES `question_type` (`id`)
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
  CONSTRAINT `user_evaluation_evaluation_FK` FOREIGN KEY (`evaluation_id`) REFERENCES `evaluations` (`id`),
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

CREATE TABLE `resources` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `resource_type_id` INT(11) NOT NULL,
  `unit_id` INT(11) NOT NULL,
  `topic_id` INT(11) NOT NULL DEFAULT '1',
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT NOT NULL,
  `url` VARCHAR(100) NOT NULL,
  `order` INT(11) NOT NULL,
  `iconName` VARCHAR(100) NOT NULL DEFAULT 'iconName',
  `createdAt` DATETIME NULL DEFAULT NULL,
  `updatedAt` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `resource_resource_type_FK` (`resource_type_id`),
  INDEX `resource_unit_FK` (`unit_id`),
  INDEX `resource_topic_FK` (`topic_id`),
  CONSTRAINT `resource_resource_type_FK` FOREIGN KEY (`resource_type_id`) REFERENCES `resource_type` (`id`),
  CONSTRAINT `resource_topic_FK` FOREIGN KEY (`topic_id`) REFERENCES `topics` (`id`),
  CONSTRAINT `resource_unit_FK` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ****************************************************************************
-- VISTAS
-- ****************************************************************************
CREATE OR REPLACE VIEW videos
AS
	SELECT a.id
	       , a.name
	       , a.description
	       , a.url
	       , a.order
	       , a.createdAt
	       , a.updatedAt
	       , c.id AS unitId
	       , c.name AS unitName
	FROM   resources a
	       INNER JOIN resource_type b
	               ON b.id = a.resource_type_id
	       INNER JOIN units c
	               ON c.id = a.unit_id
	WHERE  resource_type_id = 1
	ORDER BY
	       c.order
	       , a.order;

-- ****************************************************************************
-- USUARIOS
-- ****************************************************************************

INSERT INTO unadroid.users
(id, email, password, firstName, lastName, createdAt, updatedAt)
VALUES(1, 'pabloasalgado@gmail.com', 'Unad2018', 'Pablo ', 'Salgado ', NOW(), NOW());

INSERT INTO unadroid.users
(id, email, password, firstName, lastName, createdAt, updatedAt)
VALUES(2, 'jsebascalle@gmail.com', 'Unad2018', 'Juan', 'Calle', NOW(), NOW());

INSERT INTO unadroid.users
(id, email, password, firstName, lastName, createdAt, updatedAt)
VALUES(3, 'arsensys@gmail.com', 'Unad2018', 'Yersson', 'Malaver', NOW(), NOW());

-- ****************************************************************************
-- TIPO DE RECURSO
-- ****************************************************************************

INSERT INTO unadroid.resource_type
(id, name, createdAt, updatedAt)
VALUES(1, 'Video', NOW(), NOW());

INSERT INTO unadroid.resource_type
(id, name, createdAt, updatedAt)
VALUES(2, 'PDF', NOW(), NOW());

INSERT INTO unadroid.resource_type
(id, name, createdAt, updatedAt)
VALUES(3, 'HTML', NOW(), NOW());

INSERT INTO unadroid.resource_type
(id, name, createdAt, updatedAt)
VALUES(4, 'Image', NOW(), NOW());

-- ****************************************************************************
-- UNIDADES
-- ****************************************************************************

INSERT INTO unadroid.units
(id, name, `order`, description, iconName, createdAt, updatedAt)
VALUES(1, 'Unidad 1', 1, 'Aspectos Básicos de Android', 'unit_1_icon', NOW(), NOW());

INSERT INTO unadroid.units
(id, name, `order`, description, iconName, createdAt, updatedAt)
VALUES(2, 'Unidad 2', 2, 'Conceptos fundamentales', 'unit_2_icon', NOW(), NOW());

INSERT INTO unadroid.units
(id, name, `order`, description, iconName, createdAt, updatedAt)
VALUES(3, 'Unidad 3', 3, 'Desarrollo de una app ', 'unit_3_icon', NOW(), NOW());

-- ****************************************************************************
-- Tópicos
-- ****************************************************************************

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(1, 'Introducción al lenguaje Java', '-', 1, 1, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(2, 'Introducción Android', '-', 2, 1, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(3, 'Entorno de desarrollo', NULL, 3, 1, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(6, 'Actividades', NULL, 1, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(7, 'Intents y filtros de Intents', NULL, 2, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(8, 'Interfaz de usuario y navegación', NULL, 3, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(9, 'Animaciones y transiciones', NULL, 4, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(10, 'Imágenes y gráficos', NULL, 5, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(11, 'Audio y video ', NULL, 6, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(12, 'Tareas en segundo plano', NULL, 7, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(13, 'Archivos y datos de la app', NULL, 8, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(14, 'Identidad y datos de usuario', NULL, 9, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(15, 'Ubicación del usuario', NULL, 10, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(16, 'Modo táctil y método de entrada', NULL, 11, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(17, 'Cámara', NULL, 12, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(18, 'Sensores', NULL, 13, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(19, 'Conectividad', NULL, 14, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(20, 'RenderScript', NULL, 15, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(21, 'Contenido basado en la Web', NULL, 16, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(22, 'Apps instantáneas', NULL, 17, 2, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(23, 'Instalación de Herramientas Android', NULL, 1, 3, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(24, 'Crear un proyecto de Android', NULL, 2, 3, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(25, 'Archivo de manifiesto', NULL, 3, 3, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(26, 'Permisos de la app', NULL, 4, 3, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(27, 'Prueba', NULL, 5, 3, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(28, 'Rendimiento', NULL, 6, 3, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(29, 'Accesibilidad', NULL, 7, 3, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(30, 'Seguridad', NULL, 8, 3, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(31, 'Cómo crear contenido para miles de usuarios', NULL, 9, 3, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(32, 'Cómo crear compilaciones', NULL, 10, 3, NOW(), NOW());

INSERT INTO unadroid.topics
(id, name, description, `order`, unit_id, createdAt, updatedAt)
VALUES(33, 'Google Play', NULL, 11, 3, NOW(), NOW());

-- ****************************************************************************
-- RECURSOS
-- ****************************************************************************
INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(1, 3, 1, 1, 'Características de Java', 'Documento HTML', 'https://arquitecturamira.webnode.es/_files/200000132-7136e7233b/java.png', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(2, 1, 1, 1, 'Instalacion de Android Studio', 'Video', 'oJFIEBgA-QU', 2, 'video', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(3, 3, 1, 1, 'Creación de clases en Java', 'Documento PDF', 'http://www.androidcurso.com/index.php/tutoriales-java-esencial/24-creacion-de-clases-en-java', 3, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(4, 3, 1, 1, 'Creación y utilización de objetos', 'Documento HTML', 'https://www.abrirllave.com/java/declarar-y-crear-un-objeto.php', 4, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(5, 3, 1, 1, 'El polimorfismo en Java', 'Documento HTML', 'https://desarrolloweb.com/articulos/polimorfismo-programacion-orientada-objetos-concepto.html', 5, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(6, 3, 1, 1, 'Clases abstractas, interfaces y herencia múltiple', 'Documento HTML', 'https://emartini.wordpress.com/2008/09/17/poo-clases-abstractas-interfaces-y-herencia-multiple/', 6, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(7, 3, 1, 1, 'El encapsulamiento y la visibilidad en Java', 'Documento PDF', 'https://es.wikibooks.org/wiki/Programaci%C3%B3n_en_Java/Encapsulamiento', 7, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(8, 3, 1, 1, 'La sobrecarga en Java', 'Documento HTML', 'http://profesores.fi-b.unam.mx/carlos/java/java_basico4_6.html', 8, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(9, 3, 1, 1, 'La herencia en Java', 'Documento HTML', 'https://devcode.la/tutoriales/calculadora-en-java/', 9, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(10, 3, 1, 1, 'Comentarios y documentación javadoc', 'Documento PDF', 'https://javadesdecero.es/basico/tipos-comentarios-ejemplos/', 10, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(11, 3, 1, 1, 'La clase Lugar', 'Documento PDF', 'http://cdn.cs76.net/2012/spring/lectures/2/lecture2-dan.pdf', 11, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(12, 3, 1, 1, 'Tipos enumerados en Java', 'Documento HTML', 'https://www.discoduroderoer.es/tipos-enumerados-en-java/', 12, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(13, 3, 1, 1, 'Las colecciones en Java', 'Documento HTML', 'https://www.adictosaltrabajo.com/tutoriales/introduccion-a-colecciones-en-java/', 13, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(14, 3, 1, 2, 'Plataforma Android', 'Documento HTML', 'https://www.xatakandroid.com/sistema-operativo/que-es-android', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(15, 3, 1, 2, 'Arquitectura Android', 'Documento HTML', 'https://developer.android.com/guide/platform/?hl=es-419', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(16, 3, 1, 2, 'Estructura de archivos', 'Documento HTML', 'https://androidstudiofaqs.com/conceptos/cual-es-la-estructura-de-un-proyecto-en-android-studio', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(17, 3, 1, 3, 'Conoce Android Studio', 'Documento HTML', 'https://developer.android.com/studio/intro/?hl=es-419', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(18, 3, 1, 3, 'Instalación de Android Studio', 'Documento HTML', 'https://developer.android.com/studio/install?hl=es-419', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(19, 3, 1, 3, 'Migrar a Android Studio', 'Documento HTML', 'https://developer.android.com/studio/intro/migrate?hl=es-419', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(20, 3, 1, 3, '
Configurar Android Studio', 'Documento HTML', 'https://developer.android.com/studio/intro/studio-config?hl=es-419', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(21, 3, 1, 3, 'Combinaciones de teclas', 'Documento HTML', 'https://developer.android.com/studio/intro/keyboard-shortcuts?hl=es-419', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(22, 3, 1, 3, 'Creación de dispositivos virtuales (AVD)', 'Documento HTML', 'https://developer.android.com/studio/run/managing-avds?hl=es-419', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(23, 3, 1, 3, 'Configurar compilación', 'Documento HTML', 'https://developer.android.com/studio/build/?hl=es-419', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(24, 3, 1, 3, 'Depuración', 'Documento HTML', 'https://developer.android.com/studio/debug/?hl=es-419', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(25, 3, 1, 3, 'Lineas de comandos', 'Documento HTML', 'https://developer.android.com/studio/command-line/?hl=es-419', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(26, 3, 1, 3, 'Solución de problemas', 'Documento HTML', 'https://developer.android.com/studio/troubleshoot?hl=es-419', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(27, 3, 1, 6, 'Introducción a las actividades', 'Documento HTML', 'https://developer.android.com/guide/components/activities/intro-activities?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(28, 3, 1, 6, 'Ciclo de vida de la actividad', 'Documento HTML', 'https://developer.android.com/guide/components/activities/activity-lifecycle?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(29, 3, 1, 6, 'Cambios en el estado de la actividad', 'Documento HTML', 'https://developer.android.com/guide/components/activities/state-changes?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(30, 3, 1, 6, 'Tareas y pila de actividades', 'Documento HTML', 'https://developer.android.com/guide/components/activities/tasks-and-back-stack?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(31, 3, 1, 6, 'Procesos y el ciclo de vida de la app', 'Documento HTML', 'https://developer.android.com/guide/components/activities/process-lifecycle?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(32, 3, 1, 6, 'Objetos parcelables y paquetes', 'Documento HTML', 'https://developer.android.com/guide/components/activities/parcelables-and-bundles?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(33, 3, 1, 6, 'Fragmentos', 'Documento HTML', 'https://developer.android.com/guide/components/fragments?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(34, 3, 1, 6, 'Cómo interactuar con otras apps', 'Documento HTML', 'https://developer.android.com/training/basics/intents/index?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(35, 3, 1, 6, 'Cómo administrar vínculos de la app', 'Documento HTML', 'https://developer.android.com/training/app-links/index?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(36, 3, 1, 6, 'Cargadores', 'Documento HTML', 'https://developer.android.com/guide/components/loaders?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(37, 3, 1, 6, 'Pantalla de Recientes', 'Documento HTML', 'https://developer.android.com/guide/components/activities/recents?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(38, 3, 1, 6, 'Compatibilidad con Multiventana', 'Documento HTML', 'https://developer.android.com/guide/topics/ui/multi-window?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(39, 3, 1, 6, 'Accesos directos a aplicaciones', 'Documento HTML', 'https://developer.android.com/guide/topics/ui/shortcuts?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(40, 3, 1, 6, 'Widgets de apps', 'Documento HTML', 'https://developer.android.com/guide/topics/appwidgets/overview?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(41, 3, 1, 7, 'Descripción general', 'Documento HTML', 'https://developer.android.com/guide/components/intents-filters?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(42, 3, 1, 7, 'Intents comunes', 'Documento HTML', 'https://developer.android.com/guide/components/intents-common?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(43, 3, 1, 8, 'Descripción general', 'Documento HTML', 'https://developer.android.com/guide/topics/ui/index?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(44, 3, 1, 8, 'Cómo crear una IU receptiva con ConstraintLayout', 'Documento HTML', 'https://developer.android.com/training/constraint-layout/index?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(45, 3, 1, 8, 'Cómo crear una lista con RecyclerView', 'Documento HTML', 'https://developer.android.com/guide/topics/ui/layout/recyclerview?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(46, 3, 1, 8, 'Cómo crear un diseño basado en tarjetas', 'Documento HTML', 'https://developer.android.com/guide/topics/ui/layout/cardview?hl=es', 1, 'html', NOW(), NOW());

INSERT INTO unadroid.resources
(id, resource_type_id, unit_id, topic_id, name, description, url, `order`, iconName, createdAt, updatedAt)
VALUES(47, 3, 1, 8, 'Cómo implementar flujos de IU adaptables', 'Documento HTML', 'https://developer.android.com/training/multiscreen/adaptui?hl=es', 1, 'html', NOW(), NOW());

-- ****************************************************************************
-- Evaluaciones
-- ****************************************************************************

-- Tipos de pregunta
--
INSERT INTO unadroid.question_type
(id, description)
VALUES(1, 'Varias opciones única respuesta');

INSERT INTO unadroid.question_type
(id, description)
VALUES(2, 'Varias opciones varias respuestas');

INSERT INTO unadroid.question_type
(id, description)
VALUES(3, 'Entrada de dato por usuario');

--
-- Evaluaciones
INSERT INTO unadroid.evaluations
(id, unit_id, name, description, createdAt, updatedAt)
VALUES(1, 1, 'Evaluacion unid. 1', 'Evaluacion unidad 1', NOW(), NOW());

INSERT INTO unadroid.evaluations
(id, unit_id, name, description, createdAt, updatedAt)
VALUES(2, 2, 'Evaluacion unid. 2', 'Evaluacion unidad 2', NOW(), NOW());

INSERT INTO unadroid.evaluations
(id, unit_id, name, description, createdAt, updatedAt)
VALUES(3, 3, 'Evaluacion unid. 3', 'Evaluacion unidad 3', NOW(), NOW());

--
-- Preguntas
INSERT INTO unadroid.evaluation_question
(id, evaluation_id, question_type_id, question, createdAt, updatedAt)
VALUES(1, 1, 1, '¿Qué es Android?', NOW(), NOW());

--
-- Respuestas
INSERT INTO unadroid.evaluation_answer
(id, evaluation_question_id, answer, correct, createdAt, updatedAt)
VALUES(1, 1, 'Un sistema operativo.', 1, NOW(), NOW());

INSERT INTO unadroid.evaluation_answer
(id, evaluation_question_id, answer, correct, createdAt, updatedAt)
VALUES(2, 1, 'Un lenguaje de progrmación.', 0, NOW(), NOW());

INSERT INTO unadroid.evaluation_answer
(id, evaluation_question_id, answer, correct, createdAt, updatedAt)
VALUES(3, 1, 'Un tipo teléfono movíl.', 0, NOW(), NOW());

INSERT INTO unadroid.evaluation_answer
(id, evaluation_question_id, answer, correct, createdAt, updatedAt)
VALUES(4, 1, 'Ninguna de las anteriores.', 0, NOW(), NOW());
