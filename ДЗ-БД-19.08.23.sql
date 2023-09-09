/*1. �������� �������, ������� ������� ������ ���� ���������������� ��� ������
	SQL Server, � �� ����� ������� � ������*/
--DROP FUNCTION dbo.DataBasesList

CREATE FUNCTION DataBasesList()
RETURNS TABLE AS RETURN
(SELECT DB_NAME(database_id) AS DatabaseName,
        SUM(size * 8) AS TotalSizeBytes
    FROM sys.master_files
    GROUP BY
        database_id)

SELECT* FROM DataBasesList() --�������� ��� dbo.

/*4 -�������� �������, ������� ������� ���� �������������, �������������� � ���� ������*/
CREATE FUNCTION dbo.GetDatabaseUsers()
RETURNS TABLE
AS
RETURN
(
    SELECT
        sp.name AS UserName,
        dp.name AS RoleName
    FROM
        sys.database_principals sp
    LEFT JOIN
        sys.database_role_members drm ON sp.principal_id = drm.member_principal_id
    LEFT JOIN
        sys.database_principals dp ON drm.role_principal_id = dp.principal_id
    WHERE
        sp.type_desc IN ('WINDOWS_USER', 'SQL_USER')
        AND sp.name NOT IN ('guest', 'INFORMATION_SCHEMA', 'sys', '##MS_PolicyEventProcessingLogin##')
)

SELECT * FROM dbo.GetDatabaseUsers()

/*2-�������� �������, ������� ������� ������ ���� ������ ���� ������, �������� ������� ��������
��� ��������, ���������� ������� � ������ �� �� ������, � ����� ������ ������ ������� � ������*/
ALTER FUNCTION TablesInfo(@DataBaseName nvarchar(150))
RETURNS TABLE AS RETURN
SELECT t.name AS table_name, p.rows AS table_rows, SUM(a.total_pages) * 8 AS table_size
FROM sys.tables t JOIN sys.partitions p
ON t.object_id = p.object_id
JOIN sys.allocation_units a
ON a.container_id = p.partition_id
GROUP BY t.name, p.rows, a.total_pages

SELECT*
FROM dbo.TablesInfo('Hospital')

