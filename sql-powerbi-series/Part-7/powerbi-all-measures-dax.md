SQL + Power BI Series — All\_Measures folders + full DAX


## Create empty table first:

All\_Measures =
FILTER(
{ (1) },
FALSE()
)
---



============================================================
FOLDER 1: Fees KPIs
===

Total Collected =
SUM ( FactFee\[Amount\_Paid] )

Total Due =
SUM ( FactFee\[Amount\_Due] )

Outstanding =
\[Total Due] - \[Total Collected]

Collection % =
DIVIDE ( \[Total Collected], \[Total Due] )



============================================================
FOLDER 2: Counts
===

Fee Lines =
COUNTROWS ( FactFee )

Students =
DISTINCTCOUNT ( FactFee\[Student\_ID] )

Campuses =
DISTINCTCOUNT ( FactFee\[Campus\_ID] )

Programs =
DISTINCTCOUNT ( FactFee\[Program\_ID] )



============================================================
FOLDER 3: Fees by Head
===

Collected Tuition =
CALCULATE (
\[Total Collected],
FactFee\[Fee\_Head] = "Tuition"
)

Collected Hostel =
CALCULATE (
\[Total Collected],
FactFee\[Fee\_Head] = "Hostel"
)

Collected Exam =
CALCULATE (
\[Total Collected],
FactFee\[Fee\_Head] = "Exam"
)

Collected Transport =
CALCULATE (
\[Total Collected],
FactFee\[Fee\_Head] = "Transport"
)

Collected Application =
CALCULATE (
\[Total Collected],
FactFee\[Fee\_Head] = "Application"
)



============================================================
FOLDER 4: Fees by Campus Type
===

Collected School =
CALCULATE (
\[Total Collected],
DimCampus\[Campus\_Type] = "School"
)

Collected University =
CALCULATE (
\[Total Collected],
DimCampus\[Campus\_Type] = "University"
)

Collected International =
CALCULATE (
\[Total Collected],
DimCampus\[Campus\_Type] = "International"
)

Due School =
CALCULATE (
\[Total Due],
DimCampus\[Campus\_Type] = "School"
)

Due University =
CALCULATE (
\[Total Due],
DimCampus\[Campus\_Type] = "University"
)

Due International =
CALCULATE (
\[Total Due],
DimCampus\[Campus\_Type] = "International"
)



============================================================
FOLDER 5: Admissions

===

Applications =
DISTINCTCOUNT ( FactFee\[Application\_ID] )

Students Enrolled =
CALCULATE (
DISTINCTCOUNT ( FactFee\[Student\_ID] ),
FactFee\[Admission\_Status] = "Enrolled"
)

Students Offered =
CALCULATE (
DISTINCTCOUNT ( FactFee\[Student\_ID] ),
FactFee\[Admission\_Status] = "Offered"
)

Students Applied =
CALCULATE (
DISTINCTCOUNT ( FactFee\[Student\_ID] ),
FactFee\[Admission\_Status] = "Applied"
)

Students Withdrawn =
CALCULATE (
DISTINCTCOUNT ( FactFee\[Student\_ID] ),
FactFee\[Admission\_Status] = "Withdrawn"
)

Enrollment Rate % =
DIVIDE (
\[Students Enrolled],
\[Applications]
)

Avg Entrance Score =
AVERAGE ( FactFee\[Entrance\_Score] )



============================================================
FOLDER 6: Journey
(School → Tmity University path)
===

Students From Tmity School =
CALCULATE (
DISTINCTCOUNT ( DimStudent\[Student\_ID] ),
DimStudent\[From\_Tmity\_School] = "Yes"
)

Students Not From Tmity School =
CALCULATE (
DISTINCTCOUNT ( DimStudent\[Student\_ID] ),
DimStudent\[From\_Tmity\_School] = "No"
)

School Students Now In University =
CALCULATE (
DISTINCTCOUNT ( FactFee\[Student\_ID] ),
DimStudent\[From\_Tmity\_School] = "Yes",
DimCampus\[Campus\_Type] = "University"
)

School To University Retention % =
DIVIDE (
\[School Students Now In University],
\[Students From Tmity School]
)



============================================================
FOLDER 7: Placements
===

Placement Eligible Students =
CALCULATE (
DISTINCTCOUNT ( FactFee\[Student\_ID] ),
FactFee\[Placement\_Eligible] = "Yes"
)

Placement Offered Students =
CALCULATE (
DISTINCTCOUNT ( FactFee\[Student\_ID] ),
FactFee\[Drive\_Status] IN { "Offered", "Joined" }
)

Placement Joined Students =
CALCULATE (
DISTINCTCOUNT ( FactFee\[Student\_ID] ),
FactFee\[Drive\_Status] = "Joined"
)

Avg Package LPA =
AVERAGE ( FactFee\[Package\_LPA] )

Offer Rate % =
DIVIDE (
\[Placement Offered Students],
\[Placement Eligible Students]
)



============================================================
FOLDER SUMMARY 
===

All\_Measures
├── Fees KPIs              (4)  Total Collected, Total Due, Outstanding, Collection %
├── Counts                 (4)  Fee Lines, Students, Campuses, Programs
├── Fees by Head           (5)  Tuition / Hostel / Exam / Transport / Application
├── Fees by Campus Type    (6)  Collected + Due for School / University / International
├── Admissions             (7)  Applications, statuses, Enrollment Rate %, Avg Entrance
├── Journey                (4)  From school, retention to University
└── Placements             (5)  Eligible, Offered, Joined, Avg Package, Offer Rate %

Total measures: 35



# ===================================================

