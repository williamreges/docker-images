-- db.roles definition

CREATE TABLE `roles` (
  `codigoid` bigint NOT NULL AUTO_INCREMENT,
  `desc_role` text NOT NULL,
  PRIMARY KEY (`codigoid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- db.users definition

CREATE TABLE `users` (
  `codigoid` bigint NOT NULL AUTO_INCREMENT,
  `cod_idef_pessoa` text NOT NULL,
  `user_name` text,
  `password` text,
  PRIMARY KEY (`codigoid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- db.users_roles definition

CREATE TABLE `users_roles` (
  `codigoid_user` bigint NOT NULL,
  `codigoid_role` bigint NOT NULL,
  KEY `codigoid_user` (`codigoid_user`),
  KEY `codigoid_role` (`codigoid_role`),
  CONSTRAINT `users_roles_ibfk_1` FOREIGN KEY (`codigoid_user`) REFERENCES `users` (`codigoid`),
  CONSTRAINT `users_roles_ibfk_2` FOREIGN KEY (`codigoid_role`) REFERENCES `roles` (`codigoid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Insert Roles
INSERT INTO db.roles(codigoid, desc_role)VALUES(1, 'ROLE_INSERT');
INSERT INTO db.roles(codigoid, desc_role)VALUES(2, 'ROLE_UPDATE');
INSERT INTO db.roles(codigoid, desc_role)VALUES(3, 'ROLE_DELETE');
INSERT INTO db.roles(codigoid, desc_role)VALUES(4, 'ROLE_SELECT');


-- insert user with all permitions - username: william@gmail.com, password: 1234
INSERT INTO db.users VALUES (1, 'f53fa632-fe3d-40e8-a5c8-869d2e79b5cd', 'william@gmail.com', '$2a$10$V0go3mIsOJwl3Q.8Dm/n1u5iW4Jyx/QpYwKmhn1MGt8hZXwbricd.');
INSERT INTO db.users_roles VALUES (1, 1);
INSERT INTO db.users_roles VALUES (1, 2);
INSERT INTO db.users_roles VALUES (1, 3);
INSERT INTO db.users_roles VALUES (1, 4);

-- insert user with all permitions - username: wellington@gmail.com, password: 1234
INSERT INTO db.users VALUES (2, 'edee60aa-e43d-4517-8877-47ab14f74ae6', 'wellington@gmail.com', '$2a$10$ALa9x6AlN.ClsDqOhmTrAuBVFC0AupmewDXL0SoKUnLb.qe1EFEyy');
INSERT INTO db.users_roles VALUES (2, 4);
