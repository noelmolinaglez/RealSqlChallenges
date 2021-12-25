
CREATE OR ALTER PROCEDURE [HumanResources].[SP_GET_DEPARTMENTS_SUMMARY]
AS
BEGIN

    DECLARE @CurrentDate DATE = getdate();
    DECLARE @DepartmentsValues TABLE(
                                        DepartmentID smallint,
                                        Value int,
                                        Type varchar(20)
                                    );

    INSERT INTO @DepartmentsValues
    SELECT eh.DepartmentID,
           COUNT(*),
           'EmployeesCount'
    FROM AdventureWorks2012.HumanResources.EmployeeDepartmentHistory eh
    WHERE eh.EndDate IS NULL
    GROUP BY eh.DepartmentID;

    INSERT INTO @DepartmentsValues
    SELECT eh.DepartmentID,
           COUNT(*),
           'MalesEmployees'
    FROM AdventureWorks2012.HumanResources.EmployeeDepartmentHistory eh
             INNER JOIN AdventureWorks2012.HumanResources.Employee e on e.BusinessEntityID = eh.BusinessEntityID
    WHERE e.Gender = 'M'
    AND eh.EndDate IS NULL
    GROUP BY eh.DepartmentID;

    INSERT INTO @DepartmentsValues
    SELECT eh.DepartmentID,
           COUNT(*),
           'FemalesEmployees'
    FROM AdventureWorks2012.HumanResources.EmployeeDepartmentHistory eh
             INNER JOIN AdventureWorks2012.HumanResources.Employee e on e.BusinessEntityID = eh.BusinessEntityID
    WHERE e.Gender = 'F'
    AND eh.EndDate IS NULL
    GROUP BY eh.DepartmentID;

    INSERT INTO @DepartmentsValues
    SELECT eh.DepartmentID,
           AVG(DATEDIFF(YEAR, e.HireDate, @currentDate)),
           'years'
    FROM AdventureWorks2012.HumanResources.EmployeeDepartmentHistory eh
             INNER JOIN AdventureWorks2012.HumanResources.Employee e on e.BusinessEntityID = eh.BusinessEntityID
    GROUP BY eh.DepartmentID;

    SELECT
        name as 'DepartmentName',
        ISNULL([EmployeesCount],0) as 'EmployeesCount',
        ISNULL([MalesEmployees],0) as 'MaleEmployees',
        IIF(ISNULL([MalesEmployees],0) = 0,0,ROUND([MalesEmployees] * 100 /[EmployeesCount],2)) as 'MalePercent',
        ISNULL([FemalesEmployees],0) as 'FemaleEmployees',
        IIF(ISNULL([FemalesEmployees],0) = 0,0,ROUND([FemalesEmployees] * 100 /[EmployeesCount],2)) as 'FemalePercent',
        ISNULL([years],0) as 'AvgWorkingTime'
    FROM
        (
            SELECT d.name, value, type
            FROM @DepartmentsValues dt
            INNER JOIN AdventureWorks2012.HumanResources.Department d on d.DepartmentID = dt.DepartmentID
        ) AS SourceTable
            PIVOT
            (MAX(value)
            FOR type IN ([EmployeesCount], [MalesEmployees], [FemalesEmployees], [years])
            ) AS PivotTable;

END
GO