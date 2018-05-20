DROP TABLE `users`;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `createdAt` datetime,
  `updatedAt` datetime,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_UN` (`email`)
) ENGINE=InnoDB;

INSERT INTO unadroid.users
(email, password, createdAt, updatedAt)
VALUES('pabloasalgado@gmail.com', 'encriptar', NOW(), NOW());
