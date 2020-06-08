SET NOCOUNT ON;
BEGIN TRY
    CREATE TABLE #WinNames
    (WinID   VARCHAR(128), 
     WinName VARCHAR(MAX)
    );
    INSERT INTO #WinNames
    VALUES
    ('5.2 (3790)', 
     'Windows Server 2003 R2'
    );
    INSERT INTO #WinNames
    VALUES
    ('5.2 ()', 
     'Windows Server 2003 R2'
    );
    INSERT INTO #WinNames
    VALUES
    ('6.0 (6002)', 
     'Windows Server 2008'
    );
    INSERT INTO #WinNames
    VALUES
    ('6.1 (7601)', 
     'Windows Server 2008 R2'
    );
    INSERT INTO #WinNames
    VALUES
    ('6.2 (9200)', 
     'Windows Server 2012'
    );
    INSERT INTO #WinNames
    VALUES
    ('6.3 (9600)', 
     'Windows Server 2012 R2'
    );
    INSERT INTO #WinNames
    VALUES
    ('6.3 (14393)', 
     'Windows Server 2016'
    );
    DECLARE @Plat TABLE
    (Id             INT, 
     Name           VARCHAR(180), 
     InternalValue  VARCHAR(50), 
     Charactervalue VARCHAR(50)
    );
    DECLARE @Platform VARCHAR(100), @WinName VARCHAR(128);
    INSERT INTO @Plat
    EXEC xp_msver 
         WindowsVersion;
    SELECT @WinName = WinName
    FROM #WinNames A
         INNER JOIN @Plat B ON A.WinID = B.Charactervalue;
    DELETE @PLAT;
    DECLARE @CurrID INT, @ExistValue INT, @MaxID INT, @SQL NVARCHAR(1000);
    DECLARE @TCPPorts TABLE
    (PortType NVARCHAR(180), 
     Port     INT
    );
    IF OBJECT_ID('tempdb..#InstanceName') IS NOT NULL
        DROP TABLE #InstanceName;
    CREATE TABLE #InstanceName
    (Data1        VARCHAR(128), 
     InstanceName VARCHAR(128), 
     Data3        VARCHAR(128)
    );
    INSERT INTO #InstanceName
    EXECUTE xp_regread 
            @rootkey = 'HKEY_LOCAL_MACHINE', 
            @key = 'SOFTWARE\Microsoft\Microsoft SQL Server', 
            @value_name = 'InstalledInstances';
    UPDATE #InstanceName
      SET 
          InstanceName = REPLACE(InstanceName, 'MSSQLSERVER', 'Default');
    DECLARE @Ret_Value INT, @CPU_0_Desc VARCHAR(500), @CPU_0_MHz INTEGER, @CPU_1_Desc VARCHAR(500), @CPU_1_MHz INTEGER, @SystemManufacturer VARCHAR(500), @SystemFamily VARCHAR(100), @SystemProductName VARCHAR(100), @AutoUpdate VARCHAR(100);
    CREATE TABLE #memorydetails
    (indexs INT, 
     name   VARCHAR(30), 
     Value  NVARCHAR(30), 
     CValue NVARCHAR(30)
    );
    INSERT INTO #memorydetails
    EXEC xp_msver 
         PhysicalMemory;
    DECLARE @memory NVARCHAR(30);
    SELECT @memory = Value
    FROM #memorydetails;
    CREATE TABLE #cpudetails
    (indexs INT, 
     name   VARCHAR(30), 
     Value  NVARCHAR(30), 
     CValue NVARCHAR(30)
    );
    INSERT INTO #cpudetails
    EXEC xp_msver 
         ProcessorCount;
    DECLARE @ProcessorCount NVARCHAR(30);
    SELECT @ProcessorCount = Value
    FROM #cpudetails;
    EXEC @Ret_Value = master..xp_instance_regread 
         'HKEY_LOCAL_MACHINE', 
         'HARDWARE\DESCRIPTION\System\BIOS', 
         'SystemManufacturer', 
         @param = @SystemManufacturer OUTPUT;
    DECLARE @WindowsCluster VARCHAR(128);
    EXEC master..xp_instance_regread 
         N'HKEY_LOCAL_MACHINE', 
         N'CLUSTER', 
         N'CLUSTERNAME', 
         @param = @WindowsCluster OUTPUT;
    DECLARE @WindowsRDP INT;
    EXEC master..xp_instance_regread 
         N'HKEY_LOCAL_MACHINE', 
         N'System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp', 
         N'PortNumber', 
         @param = @WindowsRDP OUTPUT;
    EXEC @Ret_Value = master..xp_instance_regread 
         'HKEY_LOCAL_MACHINE', 
         'HARDWARE\DESCRIPTION\System\BIOS', 
         'SystemFamily', 
         @param = @SystemFamily OUTPUT;
    EXEC @Ret_Value = master..xp_instance_regread 
         'HKEY_LOCAL_MACHINE', 
         'HARDWARE\DESCRIPTION\System\BIOS', 
         'SystemProductName', 
         @param = @SystemProductName OUTPUT;
    DECLARE @DBEngineLogin VARCHAR(100);
    DECLARE @AgentLogin VARCHAR(100);
    EXECUTE master.dbo.xp_instance_regread 
            @rootkey = N'HKEY_LOCAL_MACHINE', 
            @key = N'SYSTEM\CurrentControlSet\Services\MSSQLServer', 
            @value_name = N'ObjectName', 
            @value = @DBEngineLogin OUTPUT;
    EXECUTE master.dbo.xp_instance_regread 
            @rootkey = N'HKEY_LOCAL_MACHINE', 
            @key = N'SYSTEM\CurrentControlSet\Services\SQLServerAgent', 
            @value_name = N'ObjectName', 
            @value = @AgentLogin OUTPUT;
    DECLARE @Domain VARCHAR(100), @key VARCHAR(100);
    SET @key = 'SYSTEM\ControlSet001\Services\Tcpip\Parameters\';
    EXEC master..xp_regread 
         @rootkey = 'HKEY_LOCAL_MACHINE', 
         @key = @key, 
         @value_name = 'Domain', 
         @value = @Domain OUTPUT;
    EXECUTE master.dbo.xp_instance_regread 
            'HKEY_LOCAL_MACHINE', 
            'SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU', 
            'AUOptions', 
            @param = @AutoUpdate OUTPUT;
    EXECUTE @Ret_Value = master.dbo.xp_instance_regread 
            'HKEY_LOCAL_MACHINE', 
            'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 
            'ProcessorNameString', 
            @param = @CPU_0_Desc OUTPUT;
    EXECUTE @Ret_Value = master.dbo.xp_instance_regread 
            'HKEY_LOCAL_MACHINE', 
            'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 
            '~MHz', 
            @param = @CPU_0_MHz OUTPUT;
    EXECUTE @Ret_Value = master.dbo.xp_instance_regread 
            'HKEY_LOCAL_MACHINE', 
            'HARDWARE\DESCRIPTION\System\CentralProcessor\1', 
            'ProcessorNameString', 
            @param = @CPU_1_Desc OUTPUT;
    EXECUTE @Ret_Value = master.dbo.xp_instance_regread 
            'HKEY_LOCAL_MACHINE', 
            'HARDWARE\DESCRIPTION\System\CentralProcessor\1', 
            '~MHz', 
            @param = @CPU_1_MHz OUTPUT;
    SELECT SERVERPROPERTY('ServerName') ServerName, 
           CONNECTIONPROPERTY('local_tcp_port') PortNumber,
           CASE
               WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '8%'
               THEN 'SQL Server 2000'
               WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '9%'
               THEN 'SQL Server 2005'
               WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '10.0%'
               THEN 'SQL Server 2008'
               WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '10.5%'
               THEN 'SQL Server 2008 R2'
               WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '11%'
               THEN 'SQL Server 2012'
               WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '12%'
               THEN 'SQL Server 2014'
               WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '13%'
               THEN 'SQL Server 2016'
               WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '14%'
               THEN 'SQL Server 2017'
               WHEN CONVERT(VARCHAR(128), SERVERPROPERTY('productversion')) LIKE '15%'
               THEN 'SQL Server 2019'
           END SQLVersionDesc, 
           SERVERPROPERTY(N'ProductVersion') SQLVersion, 
           SERVERPROPERTY('ProductLevel') ServicePack, 
    (
        SELECT COUNT(*)
        FROM #InstanceName
    ) TotalNoOfInstances, 
    (
        SELECT SUBSTRING(
        (
            SELECT ', ' + CONVERT(VARCHAR(10), InstanceName)
            FROM #InstanceName FOR xml PATH('')
        ), 3, 8000)
    ) AllInstancesName,
           --, SERVERPROPERTY('machinename') VirtualServerName 
           SERVERPROPERTY('ComputerNamePhysicalNetBIOS') RunningNode, 
           CONNECTIONPROPERTY('local_net_address') IPAddress, 
           @Domain DomainName,
           CASE
               WHEN SERVERPROPERTY('IsClustered') = 1
               THEN
    (
        SELECT SUBSTRING(
        (
            SELECT ' ,' + NodeName
            FROM sys.dm_os_cluster_nodes FOR xml PATH('')
        ), 3, 8000)
    )
               WHEN SERVERPROPERTY('IsClustered') = 0
               THEN 'Not Clustered'
           END AllNodes, 
           SERVERPROPERTY(N'Edition') Edition, 
           SERVERPROPERTY('ErrorLogFileName') ErrorLogLocation, 
    (
        SELECT COUNT(*)
        FROM sys.sysdatabases
        WHERE dbid > 4
    ) DBCount, 
    (
        SELECT CAST(cntr_value / 1024.0 AS DECIMAL(10, 2))
        FROM sys.dm_os_performance_counters
        WHERE instance_name LIKE '%_Total%'
              AND counter_name LIKE 'Data File(s) Size (KB)%'
    ) TotalDataSizeMB, 
    (
        SELECT CAST(cntr_value / 1024.0 AS DECIMAL(10, 2))
        FROM sys.dm_os_performance_counters
        WHERE instance_name LIKE '%_Total%'
              AND counter_name LIKE 'Log File(s) Size (KB)%'
    ) TotalLogSizeMB, 
           SERVERPROPERTY('Collation') ServerCollation, 
    (
        SELECT COUNT(*)
        FROM sys.master_files
        WHERE database_id = 2
              AND type = 0
    ) TempDBDataFileCount, 
           @ProcessorCount ProcessorCount, 
    (
        SELECT value_in_use
        FROM sys.configurations
        WHERE name LIKE 'max degree of parallelism'
    ) MAXDOP,
           --       @AutoUpdate AutoUpdate,
           @memory TotalMemory, 
    (
        SELECT value_in_use
        FROM sys.configurations
        WHERE name LIKE 'min server memory (MB)'
    ) MinMemory, 
    (
        SELECT value_in_use
        FROM sys.configurations
        WHERE name LIKE 'max server memory (MB)'
    ) MaxMemory,
           --, ISNULL(@SystemFamily,'VM') AS SystemFamily 
           @WinName WindowsName, 
           @WindowsRDP WindowsRDPPort, 
           ISNULL(@SystemManufacturer, 'VMware, Inc.') AS SystemManufacturer,
           CASE
               WHEN @SystemManufacturer <> 'VMware, Inc.'
               THEN 'Physical'
               WHEN @SystemManufacturer IS NULL
               THEN 'Virtual'
               WHEN @SystemManufacturer = 'VMware, Inc.'
               THEN 'Virtual'
           END AS [Physica/Virtual], 
           ISNULL(@SystemProductName, 'VMware Virtual Platform') AS SystemProductName, 
           @CPU_0_Desc AS [CPU Description],
           --, @CPU_0_MHz AS [CPU 0 MHz]
           --, @CPU_1_Desc AS [CPU 1 Description]
           --, @CPU_1_MHz AS [CPU 1 MHz]
           CASE
               WHEN SERVERPROPERTY('IsClustered') = 0
               THEN 'No'
               WHEN SERVERPROPERTY('IsClustered') = 1
               THEN 'Yes'
           END IsClustered, 
           ISNULL(@WindowsCluster, 'Not Cluster') WindowsCluster, 
           [DBEngineLogin] = @DBEngineLogin, 
           [AgentLogin] = @AgentLogin, 
    (
        SELECT create_date
        FROM sys.databases
        WHERE name LIKE 'tempdb'
    ) SQLStartTime, 
    (
        SELECT DATEADD(s, ((-1) * ([ms_ticks] / 1000)), GETDATE())
        FROM sys.[dm_os_sys_info]
    ) OSRebootTime, 
    (
        SELECT create_date
        FROM sys.server_principals
        WHERE sid = 0x010100000000000512000000
    ) SQLInstallDate,
           --(
           --    SELECT SUBSTRING(
           --                    (
           --                        SELECT ' ,'+QUOTENAME(name)
           --                        FROM sys.sysdatabases
           --                        WHERE dbid > 4 FOR XML PATH('')
           --                    ), 3, 8000)
           --) DBNames,
           GETDATE() RunTime;
END TRY
BEGIN CATCH
    PRINT 'Didn''t work for ' + @@SERVERNAME;
END CATCH;
GO
IF OBJECT_ID('tempdb..#cpudetails') IS NOT NULL
    DROP TABLE #cpudetails;
IF OBJECT_ID('tempdb..#memorydetails') IS NOT NULL
    DROP TABLE #memorydetails;
IF OBJECT_ID('tempdb..#SQLInstances') IS NOT NULL
    DROP TABLE #SQLInstances;
IF OBJECT_ID('tempdb..#WinNames') IS NOT NULL
    DROP TABLE #WinNames;
