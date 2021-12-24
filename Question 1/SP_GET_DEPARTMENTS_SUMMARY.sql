USE AdventureWorks2012

CREATE OR ALTER PROCEDURE [HumanResources].[SP_GET_DEPARTMENTS_SUMMARY]
AS
BEGIN

    DECLARE @CurrentDate DATE = getdate();
    DECLARE @DepartmentsValues TABLE(
                                        DepartmentID smallint,
                                        Value int,
                                        Type varchar(10)
                                    );

    INSERT INTO @DepartmentsValues
    SELECT eh.DepartmentID,
           COUNT(*),
           'EmployeesCount'
    FROM AdventureWorks2012.HumanResources.EmployeeDepartmentHistory eh
    WHERE eh.EndDate is null
    GROUP BY eh.DepartmentID

    INSERT INTO @DepartmentsValues
    SELECT eh.DepartmentID,
           COUNT(*),
           'MalesEmployees'
    FROM AdventureWorks2012.HumanResources.EmployeeDepartmentHistory eh
             INNER JOIN AdventureWorks2012.HumanResources.Employee e on e.BusinessEntityID = eh.BusinessEntityID
    WHERE e.Gender = 'M'
    GROUP BY eh.DepartmentID

    INSERT INTO @DepartmentsValues
    SELECT eh.DepartmentID,
           COUNT(*),
           'FemalesEmployees'
    FROM AdventureWorks2012.HumanResources.EmployeeDepartmentHistory eh
             INNER JOIN AdventureWorks2012.HumanResources.Employee e on e.BusinessEntityID = eh.BusinessEntityID
    WHERE e.Gender = 'F'
    GROUP BY eh.DepartmentID

    INSERT INTO @DepartmentsValues
    SELECT eh.DepartmentID,
           AVG(DATEDIFF(YEAR, e.HireDate, @currentDate)),
           'years'
    FROM AdventureWorks2012.HumanResources.EmployeeDepartmentHistory eh
             INNER JOIN AdventureWorks2012.HumanResources.Employee e on e.BusinessEntityID = eh.BusinessEntityID
    GROUP BY eh.DepartmentID
END
GO