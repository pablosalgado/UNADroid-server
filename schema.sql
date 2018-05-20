DROP TABLE `users`;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `firstName` varchar(100),
  `lastName` varchar(100),
  `createdAt` datetime,
  `updatedAt` datetime,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_UN` (`email`)
) ENGINE=InnoDB;

INSERT INTO unadroid.users
(email, password, firstName, lastName, createdAt, updatedAt)
VALUES('pabloasalgado@gmail.com', 'encriptar', 'Pablo', 'Salgado', NOW(), NOW());
