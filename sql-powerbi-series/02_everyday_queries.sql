/*
  Tmity_DB 
  Change the table name if you have used a different name.
*/

USE Tmity_DB;
GO

-- How to find your table name if it is not below:
-- SELECT name FROM sys.tables;

--Question list
--1. How to see the first 10 rows?  
--2. How to see only useful columns (not SELECT *)?  
--3. How many rows are in the dump?  
--4. How many unique students are in the dump?  
--5. How to filter only University campus rows?  
--6. How to filter International campus AND Tuition fee?  
--7. How to filter rows for a list of cities (Noida, Dubai, London)?  
--8. How to see the top 10 highest fee amounts?  
--9. How to get unique Campus_Type values?  
--10. How to get a unique list of campuses with city and type?  
--11. How to get unique Program_Level values?  
--12. How to find unpaid installments (Paid_Date is missing)?  
--13. How to find students with no School_Campus (not from Tmity School)?  
--14. How much fee was collected vs due by Campus_Type?  
--15. How much was collected by Fee_Head (Tuition, Hostel, etc.)?  
--16. Which cities have more than 500 students?  
--17. How to fix mixed-case Campus_Type in the result (without changing the table)?  
--18. How to clean Admission_Status values in the result (Enrolled, Offered, etc.)?

-- ------------------------------------------------------------
-- 1) How to see the first 10 rows?
-- ------------------------------------------------------------
SELECT TOP 10 *
FROM [dbo].[Tmity_University_Fee_Dump]; 

-- ------------------------------------------------------------
-- 2) How to see only useful columns (not SELECT *)?
-- ------------------------------------------------------------
SELECT TOP 10
    Fee_Txn_ID,
    Student_Name,
    Campus_Name,
    Campus_Type,
    Program_Level,
    Fee_Head,
    Amount_Due,
    Amount_Paid,
    Admission_Status
FROM [dbo].[Tmity_University_Fee_Dump];

-- ------------------------------------------------------------
-- 3) How many rows are in the dump?
-- ------------------------------------------------------------
SELECT COUNT(*) AS Total_Rows
FROM [dbo].[Tmity_University_Fee_Dump];                                                                                         

-- ------------------------------------------------------------
-- 4) How many unique students are in the dump?
-- ------------------------------------------------------------
SELECT COUNT(DISTINCT Student_ID) AS Total_Students
FROM [dbo].[Tmity_University_Fee_Dump];

-- ------------------------------------------------------------
-- 5) How to filter only University campus rows?
-- ------------------------------------------------------------
SELECT TOP 20
    Student_Name, Campus_Name, Campus_Type, Program_Name, Amount_Paid
FROM [dbo].[Tmity_University_Fee_Dump]
WHERE Campus_Type = 'University';

-- ------------------------------------------------------------
-- 6) How to filter International campus AND Tuition fee?
-- ------------------------------------------------------------
SELECT TOP 20
    Student_Name, Campus_City, Campus_Type, Fee_Head, Amount_Due
FROM [dbo].[Tmity_University_Fee_Dump]
WHERE Campus_Type = 'International'
  AND Fee_Head = 'Tuition';

-- ------------------------------------------------------------
-- 7) How to filter rows for a list of cities (Noida, Dubai, London)?
-- ------------------------------------------------------------
SELECT TOP 20
    Student_Name, Campus_City, Program_Name
FROM [dbo].[Tmity_University_Fee_Dump]
WHERE Campus_City IN ('Noida', 'Dubai', 'London');

-- ------------------------------------------------------------
-- 8) How to see the top 10 highest DUE fee amounts?
-- ------------------------------------------------------------
SELECT TOP 10
    Student_Name, Campus_Name, Fee_Head, Amount_Due, Due_Date
FROM [dbo].[Tmity_University_Fee_Dump]
ORDER BY Amount_Due DESC;

-- ------------------------------------------------------------
-- 9) How to get unique Campus_Type values?
-- ------------------------------------------------------------
SELECT DISTINCT Campus_Type
FROM [dbo].[Tmity_University_Fee_Dump];

-- ------------------------------------------------------------
-- 10) How to get a unique list of campuses with city and type?
-- ------------------------------------------------------------
SELECT DISTINCT Campus_Name, Campus_Type, Campus_City
FROM [dbo].[Tmity_University_Fee_Dump];

-- ------------------------------------------------------------
-- 11) How to get unique Program_Level values?
-- ------------------------------------------------------------
SELECT DISTINCT Program_Level
FROM [dbo].[Tmity_University_Fee_Dump];

-- ------------------------------------------------------------
-- 12) How to find unpaid installments (Paid_Date is missing)?
-- ------------------------------------------------------------
SELECT TOP 20
    Student_Name, Paid_Date, Amount_Paid, Amount_Due
FROM [dbo].[Tmity_University_Fee_Dump]
WHERE Paid_Date IS NULL;

-- ------------------------------------------------------------
-- 13) How to find students with no School_Campus (not from Tmity School)?
-- ------------------------------------------------------------
SELECT TOP 20
    Student_Name, School_Campus, From_Tmity_School, Campus_Type
FROM [dbo].[Tmity_University_Fee_Dump]
WHERE School_Campus IS NULL
   OR School_Campus = '';

-- ------------------------------------------------------------
-- 14) How much fee was collected vs due by Campus_Type?
-- ------------------------------------------------------------
SELECT
    Campus_Type,
    COUNT(DISTINCT Student_ID) AS Students,
    SUM(TRY_CAST(Amount_Paid AS decimal(18, 2))) AS Collected,
    SUM(TRY_CAST(Amount_Due AS decimal(18, 2))) AS Due_Amt
FROM [dbo].[Tmity_University_Fee_Dump]
GROUP BY Campus_Type
ORDER BY Collected DESC;

-- ------------------------------------------------------------
-- 15) How much was collected by Fee_Head (Tuition, Hostel, etc.)?
-- ------------------------------------------------------------
SELECT
    Fee_Head,
    SUM(TRY_CAST(Amount_Paid AS decimal(18, 2))) AS Collected
FROM [dbo].[Tmity_University_Fee_Dump]
GROUP BY Fee_Head
ORDER BY Collected DESC;

-- ------------------------------------------------------------
-- 16) Which cities have more than 500 students?
-- ------------------------------------------------------------
SELECT
    Campus_City,
    COUNT(DISTINCT Student_ID) AS Students
FROM [dbo].[Tmity_University_Fee_Dump]
GROUP BY Campus_City
HAVING COUNT(DISTINCT Student_ID) > 500
ORDER BY Students DESC;

-- ------------------------------------------------------------
-- 17) How to fix mixed-case Campus_Type in the result (without changing the table)?
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN LOWER(LTRIM(RTRIM(Campus_Type))) = 'school' THEN 'School'
        WHEN LOWER(LTRIM(RTRIM(Campus_Type))) = 'university' THEN 'University'
        WHEN LOWER(LTRIM(RTRIM(Campus_Type))) = 'international' THEN 'International'
        ELSE Campus_Type
    END AS Campus_Type_Clean,
    COUNT(*) AS Rows_N
FROM [dbo].[Tmity_University_Fee_Dump]
GROUP BY
    CASE
        WHEN LOWER(LTRIM(RTRIM(Campus_Type))) = 'school' THEN 'School'
        WHEN LOWER(LTRIM(RTRIM(Campus_Type))) = 'university' THEN 'University'
        WHEN LOWER(LTRIM(RTRIM(Campus_Type))) = 'international' THEN 'International'
        ELSE Campus_Type
    END;

-- ------------------------------------------------------------
-- 18) How to clean Admission_Status values in the result (Enrolled, Offered, etc.)?
-- ------------------------------------------------------------
SELECT TOP 15
    Admission_Status,
    CASE
        WHEN LOWER(LTRIM(RTRIM(Admission_Status))) IN ('enrolled') THEN 'Enrolled'
        WHEN LOWER(LTRIM(RTRIM(Admission_Status))) IN ('offered', 'offer') THEN 'Offered'
        WHEN LOWER(LTRIM(RTRIM(Admission_Status))) IN ('applied') THEN 'Applied'
        WHEN LOWER(LTRIM(RTRIM(Admission_Status))) IN ('withdrawn') THEN 'Withdrawn'
        ELSE Admission_Status
    END AS Admission_Status_Clean
FROM [dbo].[Tmity_University_Fee_Dump];


