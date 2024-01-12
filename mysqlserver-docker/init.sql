CREATE TABLE users
(
    codigoid bigint not null auto_increment,
    cod_idef_pessoa text not null,
    login_user text,
    password_user text,
    primary key(codigoid)
);