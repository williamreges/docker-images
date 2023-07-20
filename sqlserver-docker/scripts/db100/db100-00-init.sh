echo "Inicio Processamento"
echo "Aguardando instancia do SqlServer ativo ..."
sleep 120

/opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P user@1234 -d master -i /tmp/db100-01-create-database.sql
/opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P user@1234 -d master -i /tmp/db100-02-create-tables.sql
/opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P user@1234 -d master -i /tmp/db100-03-insert-data.sql
/opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P user@1234 -d master -i /tmp/db100-04-create-cdc.sql

echo "Fim processamento"