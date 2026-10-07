# SQL + Power BI Series — Part 7

Power BI: `All_Measures` DAX (folders + full measure list).

Connect Power BI to SQL Server `Tmity_DB` (Dim + Fact), then use these files.

## Files in this folder

| File | What it is |
|------|------------|
| `powerbi-all-measures-dax-query-view.dax` | Paste in **DAX query view** → Update model with changes |
| `powerbi-all-measures-dax.md` | Folder names + which measure goes in each folder |

## Quick steps

1. Create empty table: `All_Measures = FILTER ( { (1) }, FALSE() )`
2. Open DAX query view → paste the `.dax` file → **Update model with changes**
3. Set Display folders using the `.md` guide
4. Hide the dummy column on `All_Measures`
