# SQL + Power BI Series

Practice files for the **SQL + Power BI Series** (DataWithPranav).

## Case study

**Tmity University** — fictional education group (School / University / International).
One row in the CSV = one fee installment (not one student).

## Files

| Part | File | What it is |
|------|------|------------|
| Part 1 | `Tmity_University_Fee_Dump.csv` | Master ERP dump for SQL Server import |
| Part 2 | `02_everyday_queries.sql` | Everyday analyst queries (SELECT, WHERE, GROUP BY, CASE, …) |
| Part 4 | `04_normalize.sql` | Split dump into DimCampus, DimProgram, DimStudent, FactFee |
| Part 7 | `powerbi-all-measures-dax-query-view.dax` | Paste in Power BI DAX query view → Update model (all measures) |
| Part 7 | `powerbi-all-measures-dax.md` | All_Measures folder list + DAX reference |

## Database tip

Import into SQL Server Express as database `Tmity_DB`.
Table name from the Import Flat File wizard is often `Tmity_University_Fee_Dump`.
