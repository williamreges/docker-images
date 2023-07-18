USE DB100;
GO
--Habilitar CDC no SqlServer
EXEC sys.sp_cdc_enable_db;

--Habilitar o CDC nas tabelas PESSOA
EXEC sys.sp_cdc_enable_table
@source_schema = N'dbo',
@source_name = N'PESSOA',
@role_name = N'public',
@filegroup_name = N'PRIMARY',
@supports_net_changes = 0;

--Visualiza os CDCS criados
--EXEC sys.sp_cdc_help_change_data_capture;