/*
  Tmity_DB — Video 4: normalize one dump into Dim + Fact

  Source: dbo.Tmity_University_Fee_Dump  (one flat table)
  Target:
    dbo.DimCampus
    dbo.DimProgram
    dbo.DimStudent
    dbo.FactFee

  Why:
    One table is doing many jobs (campus, student, program, fee).
    Analysts split it so Power BI / JOINs stay clean.

  Grain stays the same:
    FactFee one row = one fee installment
*/
USE Tmity_DB;
GO


-- ============================================================
-- 1) Why split? What is repeated in the master table?
-- ============================================================

-- How many fee rows vs unique students / campuses / programs?
SELECT
    COUNT(*) AS Fee_Rows,
    COUNT(DISTINCT Student_ID) AS Students,
    COUNT(DISTINCT Campus_Name) AS Campus_Name_Spellings,
    COUNT(DISTINCT Program_Name) AS Programs
FROM dbo.Tmity_University_Fee_Dump;

-- Same student name repeated on every installment
SELECT TOP 10 Student_ID, Student_Name, Campus_Name, Fee_Head, Amount_Due
FROM dbo.Tmity_University_Fee_Dump
WHERE Student_ID = (
    SELECT TOP 1 Student_ID
    FROM dbo.Tmity_University_Fee_Dump
    GROUP BY Student_ID
    HAVING COUNT(*) > 3
);


-- ============================================================
-- 2) How to standardize Campus_Name spellings (for keys only)?
--    CSV has a few variants: "Tmity Univ Noida" vs "Tmity University Noida"
-- ============================================================

-- Dirty spellings that exist
SELECT Campus_Name, Campus_Type, Campus_City, COUNT(*) AS Rows_N
FROM dbo.Tmity_University_Fee_Dump
GROUP BY Campus_Name, Campus_Type, Campus_City
ORDER BY Campus_Type, Campus_City, Campus_Name;

-- Helper view of canonical campus name (used when building Dim + Fact)
IF OBJECT_ID(N'dbo.vw_Dump_With_CampusKey', N'V') IS NOT NULL
    DROP VIEW dbo.vw_Dump_With_CampusKey;
GO

CREATE VIEW dbo.vw_Dump_With_CampusKey
AS
SELECT
    d.*,
    CASE
        WHEN Campus_Name IN (N'Tmity School Noida', N'Tmity School, Noida', N'Tmity Sch Noida')
            THEN N'Tmity School Noida'
        WHEN Campus_Name IN (N'Tmity School Gurugram')
            THEN N'Tmity School Gurugram'
        WHEN Campus_Name IN (N'Tmity School Lucknow')
            THEN N'Tmity School Lucknow'
        WHEN Campus_Name IN (N'Tmity School Jaipur')
            THEN N'Tmity School Jaipur'
        WHEN Campus_Name IN (N'Tmity University Noida', N'Tmity University, Noida', N'Tmity Univ Noida')
            THEN N'Tmity University Noida'
        WHEN Campus_Name IN (N'Tmity University Mumbai', N'Tmity Univ Mumbai')
            THEN N'Tmity University Mumbai'
        WHEN Campus_Name IN (N'Tmity University Jaipur')
            THEN N'Tmity University Jaipur'
        WHEN Campus_Name IN (N'Tmity University Kolkata')
            THEN N'Tmity University Kolkata'
        WHEN Campus_Name IN (N'Tmity University Raipur')
            THEN N'Tmity University Raipur'
        WHEN Campus_Name IN (N'Tmity International Dubai', N'Tmity International, Dubai', N'Tmity Intl Dubai')
            THEN N'Tmity International Dubai'
        WHEN Campus_Name IN (N'Tmity International London')
            THEN N'Tmity International London'
        WHEN Campus_Name IN (N'Tmity International Singapore')
            THEN N'Tmity International Singapore'
        WHEN Campus_Name IN (N'Tmity International Tashkent')
            THEN N'Tmity International Tashkent'
        ELSE Campus_Name
    END AS Campus_Name_Key
FROM dbo.Tmity_University_Fee_Dump AS d;
GO

-- After key: fewer campuses
SELECT Campus_Name_Key, Campus_Type, Campus_City, COUNT(*) AS Rows_N
FROM dbo.vw_Dump_With_CampusKey
GROUP BY Campus_Name_Key, Campus_Type, Campus_City
ORDER BY Campus_Type, Campus_City;


-- ============================================================
-- 3) How to create DimCampus?
-- ============================================================

IF OBJECT_ID(N'dbo.FactFee', N'U') IS NOT NULL DROP TABLE dbo.FactFee;
IF OBJECT_ID(N'dbo.DimStudent', N'U') IS NOT NULL DROP TABLE dbo.DimStudent;
IF OBJECT_ID(N'dbo.DimProgram', N'U') IS NOT NULL DROP TABLE dbo.DimProgram;
IF OBJECT_ID(N'dbo.DimCampus', N'U') IS NOT NULL DROP TABLE dbo.DimCampus;
GO

CREATE TABLE dbo.DimCampus (
    Campus_ID     int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    Campus_Name   nvarchar(100) NOT NULL UNIQUE,
    Campus_Type   nvarchar(30)  NOT NULL,
    Campus_City   nvarchar(50)  NOT NULL,
    Campus_Country nvarchar(50) NOT NULL
);
GO

INSERT INTO dbo.DimCampus (Campus_Name, Campus_Type, Campus_City, Campus_Country)
SELECT DISTINCT
    Campus_Name_Key,
    Campus_Type,
    Campus_City,
    Campus_Country
FROM dbo.vw_Dump_With_CampusKey;

SELECT * FROM dbo.DimCampus ORDER BY Campus_Type, Campus_Name;


-- ============================================================
-- 4) How to create DimProgram?
-- ============================================================

CREATE TABLE dbo.DimProgram (
    Program_ID     int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    Program_Name   nvarchar(50) NOT NULL,
    Program_Level  nvarchar(30) NOT NULL,
    CONSTRAINT UQ_DimProgram UNIQUE (Program_Name, Program_Level)
);
GO

INSERT INTO dbo.DimProgram (Program_Name, Program_Level)
SELECT DISTINCT
    Program_Name,
    Program_Level
FROM dbo.Tmity_University_Fee_Dump;

SELECT * FROM dbo.DimProgram ORDER BY Program_Level, Program_Name;


-- ============================================================
-- 5) How to create DimStudent?
-- ============================================================

CREATE TABLE dbo.DimStudent (
    Student_ID          nvarchar(20)  NOT NULL PRIMARY KEY,
    Student_Name        nvarchar(100) NOT NULL,
    Email               nvarchar(100) NULL,
    Phone               nvarchar(30)  NULL,
    Gender              nvarchar(20)  NULL,
    Home_City           nvarchar(50)  NULL,
    Home_State          nvarchar(50)  NULL,
    From_Tmity_School   nvarchar(10)  NULL,
    School_Campus       nvarchar(100) NULL
);
GO

-- One row per student (pick any row's attributes — same person)
INSERT INTO dbo.DimStudent (
    Student_ID, Student_Name, Email, Phone, Gender,
    Home_City, Home_State, From_Tmity_School, School_Campus
)
SELECT
    Student_ID,
    MAX(Student_Name) AS Student_Name,
    MAX(Email) AS Email,
    MAX(Phone) AS Phone,
    MAX(Gender) AS Gender,
    MAX(Home_City) AS Home_City,
    MAX(Home_State) AS Home_State,
    MAX(From_Tmity_School) AS From_Tmity_School,
    MAX(NULLIF(School_Campus, N'')) AS School_Campus
FROM dbo.Tmity_University_Fee_Dump
GROUP BY Student_ID;

SELECT TOP 10 * FROM dbo.DimStudent;
SELECT COUNT(*) AS Student_Count FROM dbo.DimStudent;


-- ============================================================
-- 6) How to create FactFee (the big table — only fee facts + keys)?
-- ============================================================

CREATE TABLE dbo.FactFee (
    Fee_Txn_ID          nvarchar(20)    NOT NULL PRIMARY KEY,
    Student_ID          nvarchar(20)    NOT NULL,
    Campus_ID           int             NOT NULL,
    Program_ID          int             NOT NULL,
    Installment_No      int             NULL,
    Fee_Head            nvarchar(50)    NULL,
    Academic_Year       nvarchar(20)    NULL,
    Due_Date            date            NULL,
    Amount_Due          decimal(18, 2)  NULL,
    Amount_Paid         decimal(18, 2)  NULL,
    Paid_Date           date            NULL,
    Payment_Mode        nvarchar(20)    NULL,
    Class_or_Semester   nvarchar(30)    NULL,
    Enrollment_Status   nvarchar(30)    NULL,
    Application_ID      nvarchar(30)    NULL,
    Application_Date    date            NULL,
    Offer_Date          date            NULL,
    Admission_Status    nvarchar(20)    NULL,
    Entrance_Score      decimal(5, 1)   NULL,
    Placement_Eligible  nvarchar(10)    NULL,
    Company_Name        nvarchar(50)    NULL,
    Package_LPA         decimal(6, 2)   NULL,
    Drive_Status        nvarchar(30)    NULL,
    CONSTRAINT FK_FactFee_Student FOREIGN KEY (Student_ID) REFERENCES dbo.DimStudent (Student_ID),
    CONSTRAINT FK_FactFee_Campus  FOREIGN KEY (Campus_ID)  REFERENCES dbo.DimCampus (Campus_ID),
    CONSTRAINT FK_FactFee_Program FOREIGN KEY (Program_ID) REFERENCES dbo.DimProgram (Program_ID)
);
GO

INSERT INTO dbo.FactFee (
    Fee_Txn_ID, Student_ID, Campus_ID, Program_ID,
    Installment_No, Fee_Head, Academic_Year,
    Due_Date, Amount_Due, Amount_Paid, Paid_Date, Payment_Mode,
    Class_or_Semester, Enrollment_Status,
    Application_ID, Application_Date, Offer_Date, Admission_Status, Entrance_Score,
    Placement_Eligible, Company_Name, Package_LPA, Drive_Status
)
SELECT
    d.Fee_Txn_ID,
    d.Student_ID,
    c.Campus_ID,
    p.Program_ID,
    TRY_CAST(d.Installment_No AS int),
    d.Fee_Head,
    d.Academic_Year,
    COALESCE(TRY_CONVERT(date, d.Due_Date, 23), TRY_CONVERT(date, d.Due_Date, 103)),
    TRY_CAST(d.Amount_Due AS decimal(18, 2)),
    TRY_CAST(d.Amount_Paid AS decimal(18, 2)),
    COALESCE(TRY_CONVERT(date, d.Paid_Date, 23), TRY_CONVERT(date, d.Paid_Date, 103)),
    NULLIF(d.Payment_Mode, N''),
    d.Class_or_Semester,
    d.Enrollment_Status,
    d.Application_ID,
    COALESCE(TRY_CONVERT(date, d.Application_Date, 23), TRY_CONVERT(date, d.Application_Date, 103)),
    COALESCE(TRY_CONVERT(date, d.Offer_Date, 23), TRY_CONVERT(date, d.Offer_Date, 103)),
    d.Admission_Status,
    TRY_CAST(d.Entrance_Score AS decimal(5, 1)),
    NULLIF(d.Placement_Eligible, N''),
    NULLIF(d.Company_Name, N''),
    TRY_CAST(NULLIF(d.Package_LPA, N'') AS decimal(6, 2)),
    NULLIF(d.Drive_Status, N'')
FROM dbo.vw_Dump_With_CampusKey AS d
INNER JOIN dbo.DimCampus AS c
    ON c.Campus_Name = d.Campus_Name_Key
INNER JOIN dbo.DimProgram AS p
    ON p.Program_Name = d.Program_Name
   AND p.Program_Level = d.Program_Level;

-- Row counts should match the dump
SELECT
    (SELECT COUNT(*) FROM dbo.Tmity_University_Fee_Dump) AS Dump_Rows,
    (SELECT COUNT(*) FROM dbo.FactFee) AS Fact_Rows,
    (SELECT COUNT(*) FROM dbo.DimCampus) AS Campuses,
    (SELECT COUNT(*) FROM dbo.DimProgram) AS Programs,
    (SELECT COUNT(*) FROM dbo.DimStudent) AS Students;


-- ============================================================
-- 7) How to add indexes (fee table is big)?
-- ============================================================

CREATE INDEX IX_FactFee_Student_ID ON dbo.FactFee (Student_ID);
CREATE INDEX IX_FactFee_Campus_ID  ON dbo.FactFee (Campus_ID);
CREATE INDEX IX_FactFee_Program_ID ON dbo.FactFee (Program_ID);
CREATE INDEX IX_FactFee_Due_Date   ON dbo.FactFee (Due_Date);
CREATE INDEX IX_FactFee_Academic_Year ON dbo.FactFee (Academic_Year);
GO


-- ============================================================
-- 8) How to query with JOIN (VLOOKUP in SQL)?
-- ============================================================

-- Collected by campus type (uses Dim + Fact, not the flat dump)
SELECT
    c.Campus_Type,
    COUNT(*) AS Fee_Lines,
    COUNT(DISTINCT f.Student_ID) AS Students,
    SUM(f.Amount_Paid) AS Collected,
    SUM(f.Amount_Due) AS Due_Amt
FROM dbo.FactFee AS f
INNER JOIN dbo.DimCampus AS c
    ON c.Campus_ID = f.Campus_ID
GROUP BY c.Campus_Type
ORDER BY Collected DESC;

-- One student: fee lines + campus + program names
SELECT TOP 20
    s.Student_Name,
    c.Campus_Name,
    p.Program_Name,
    f.Fee_Head,
    f.Due_Date,
    f.Amount_Due,
    f.Amount_Paid
FROM dbo.FactFee AS f
INNER JOIN dbo.DimStudent AS s ON s.Student_ID = f.Student_ID
INNER JOIN dbo.DimCampus  AS c ON c.Campus_ID  = f.Campus_ID
INNER JOIN dbo.DimProgram AS p ON p.Program_ID = f.Program_ID
ORDER BY f.Due_Date DESC;
GO
