# SQLSERVER LOCAL

----
> A imagem mcr.microsoft.com/mssql/server:2019-latest contém o serviço de banco de dados SQLServer que pode ser
> onde podemos subir um container e usar os recuros localmente como criar database, tabelas, view, cdc e dentre outros.

## Diretórios e arquivos do Projeto

| **Diretório**               | **Descrição**                                                                                                                                                                                 |
|-----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **/scripts**                | Onde fica os scripts de criação dos recursos do banco como criar database, tabelas, commandos sql dentre outros.                                                                              |
| **/workspace**              | Onde pode ser depositado os projetos de código fonte para testes em DES na ferramenta Jupyter ou Vscode attachado                                                                             |
| **docker-compose.yml**      | Arquivo responsável por subir um container da imagem do sqlserver mcr.microsoft.com/mssql/server:2019-latest e a imagem mcr.microsoft.com/mssql-tools que roda os scripts da pasta `\scripts` |
| **init-sqlserver-local.sh** | Arquivo Shell que inicializa o `docker-compose.yml` com as imagens dos serviços                                                                                                               |

---
## Configurações dos arquivos

---
### 1. Docker-compose.yml
Para um efetivo sucesso em subir um container é necessário configurar algumas parametros no `docker-compose.yml` conforme abaixo:

- #### Environment imagem SqlServer
````properties
MSSQL_SA_PASSWORD: "user@1234"
ACCEPT_EULA: "Y"
MSSQL_PID: "Developer"
MSSQL_AGENT_ENABLED: "true"
````
Obs:
> `MSSQL_AGENT_ENABLED: "true"` habilita o recurso de CDC para se trabalhar com connect entra tabelas e serviços de connect
> como kafka connect
- #### Volumes do mssqltools
````properties
./scripts/db100:/tmp
````

---
## Execução

---
Para rodar todos esses itens acima mencionado de forma automático podemos rodar via `bash` dentro do ambiente docker ou
podman, execulte da seguinte forma:
````shell
./init-sqlserver-local.sh 
````

Esse comando irá rodar o docker-compose.yml que por sua vez irá subir dois containeres das imagens:

* `mcr.microsoft.com/mssql/server:2019-latest`: container que contém o serviço de SqlServer;
* `mcr.microsoft.com/mssql-tools`: container que irá rodar os scripts `bash` na pasta `/tmp` que carrega os scripts de
  criação de database, tabelas, comandos DML e criação de CDC de tabelas para kafka connect. Exemplo disso seria o volume
  `- ./scripts/db100:/tmp` que cria uma base e uma tabema `DB100` e insere dados e posteriormente já cria um CDC para
  conectar a serviços externos como Kafka Connect.

---

## DBeaver
DBeaver Community é uma ferramenta gratuita de banco de dados multiplataforma para desenvolvedores, administradores de banco de dados, analistas e todos que trabalham com dados. Ele suporta todos os bancos de dados SQL populares, como MySQL, MariaDB, PostgreSQL, SQServer e muito mais.

Para download veja: https://dbeaver.io/download/

![img.png](images/img.png)
---

## Referencias

* [Microsoft SQL Server - Ubuntu based images](https://mcr.microsoft.com/en-us/product/mssql/server/about)
* [DBeaver](https://dbeaver.io/)
* [Plugin Connector - Sqlserver](https://debezium.io/documentation/reference/stable/connectors/sqlserver.html)
* [Enabling CDC on the SQL Server database](https://debezium.io/documentation/reference/stable/connectors/sqlserver.html#_enabling_cdc_on_the_sql_server_database)
* [KAFKA Connect](https://kafka.apache.org/documentation.html#connect)