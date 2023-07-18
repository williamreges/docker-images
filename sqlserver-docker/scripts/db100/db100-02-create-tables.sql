USE DB100;
GO

CREATE TABLE PESSOA (
   ID        varchar(36)          not null,
   NOME        VARCHAR(255)             not null,
   IDADE   int                  not null,
   SALARIO   decimal(15, 2)       not null,
   ATIVO   char(1)              not null  default 'S',
   DAT_ADMISSAO         datetime             not null
 PRIMARY KEY (ID)
);