# Repository Guidelines

## Project Structure & Module Organization

This repository contains standalone SAP Business One queries for SAP HANA. Source files live in the repository root:

- `SAP_B1_HANA_*.sql`: replenishment, batch stock, sales-order reporting, and ProcessForce metadata queries.
- `JG_MonthlyStockReport_SemiFinishedOnly_v4_ByItem.sql`: a schema-qualified monthly stock report view definition.
- `Resources.cs`: a C# snippet for SAP B1 manufacturing-order UI automation; it requires host-provided objects such as `form` and `application`.

There are no dedicated test or asset directories, application projects, or dependency manifests. Keep new standalone queries in the root and exclude temporary research files and exported business data from contributions.

Environment reference inventories live in `docs/`; consult the linked KB sources when checking object names.

For CompuTec behavior and integrations, start with [docs/computec/README.md](docs/computec/README.md), then read the relevant product guide. Keep version-specific vendor capabilities separate from confirmed company configuration.

For Boyum B1UP, start with [docs/boyum/README.md](docs/boyum/README.md) for the installed version, module flags, and configuration capture scope.

## Build, Test, and Development Commands

There is no repository build, local application server, or automated test command.

- Run individual query statements in SAP B1 Query Manager or a HANA SQL console connected to a test company schema.
- Run `SELECT CURRENT_SCHEMA, CURRENT_USER FROM DUMMY;` to verify connection context.
- For the ProcessForce export, execute numbered sections separately in Query Manager; export results with the filenames specified in its comments.
- Run `git diff --check` before submitting to detect whitespace errors in tracked changes.

## Coding Style & Naming Conventions

Use four-space indentation for new SQL and C# code. Follow the newer SQL scripts: uppercase SQL keywords, double-quoted identifiers, single-quoted literals, descriptive CTE names, and explicit joins. Prefer filenames such as `SAP_B1_HANA_<Purpose>.sql`.

Start each query with a comment explaining purpose, result granularity, filters, units, and assumptions. Aggregate independent supply and stock sources before joining to prevent duplicate totals. No formatter or linter is configured.

## Testing Guidelines

Validate changes manually against a test company database. Check zero stock, missing related records, cancelled/closed documents, repeated document lines, and inventory versus purchasing units where applicable. Compare quantities and values with SAP reports. Record the environment, scenarios, and results; no automated coverage threshold exists.

## Commit & Pull Request Guidelines

Git history currently contains no commits. Use concise imperative subjects, for example `Fix RM purchase quantity aggregation`. Keep changes focused. PRs should describe affected scripts, business assumptions, validation results, and any schema requirements. Link relevant issues; include screenshots only for UI changes.

## Security & Configuration

Keep credentials and business-data exports out of Git. Review hardcoded schemas, warehouse prefixes, and item-group filters before execution. The monthly report creates a view in `CONTAMAC_LIVE`; adapt and validate it in a test schema before deployment.

## Environment Knowledge Base

### KB00: Company Schemas & Documentation Scope

- The environment contains **4 live company schemas** and **4 test schemas**.
- Main company schema: **`CONTAMAC_LIVE`** (production).
- Forthcoming environment documentation applies to `CONTAMAC_LIVE` unless explicitly stated otherwise. Use this scope for the KB entries below; do not assume settings apply to the other companies.
- Other schema names and live-to-test mappings have not yet been provided. Do not infer the test counterpart's name.
- Source: user confirmation, 2026-10-15.

### KB01: Company Currencies

- Local currency (`OADM.MainCurncy`): **GBP**.
- System currency (`OADM.SysCurrncy`): **GBP**.
- Source: user confirmation, 2026-10-15; database export not yet reviewed.

Use GBP when describing local-currency and system-currency report values. Document currencies may differ; check them separately.

### KB02: Warehouse Directory

Scope: `CONTAMAC_LIVE`. Source: user-provided KB02 results, 2026-10-15. There are 24 listed warehouses; 10 have bins activated.

| Warehouse code | Warehouse name | Bins activated |
| --- | --- | --- |
| FGEN | FINISHED GOODS UK | Y |
| FGUS | FINISHED GOODS US | Y |
| GRIN | GRINDING | Y |
| INSP | INSPECTION | N |
| INTR | INTRANSIT | N |
| LATH | LATHING | Y |
| MDRM | MEDICAL DEVICES RAW MATERIALS | N |
| MISC | MISCELLANEOUS | N |
| PACK | PACKING | Y |
| PROD | PRODUCTION RAW MATERIALS | Y |
| QCON | QUALITY CONTROL | N |
| QCPR | QC TEST PRE-RELEASE | Y |
| QCSM | QC SAMPLE ARCHIVE | N |
| QREL | QUARANTINE RELEASE | N |
| QUAR | QUARANTINE | Y |
| RECV | RECEIVING GOODS IN | N |
| RETQ | CUSTOMER RETURNS (QUARANTINED) | N |
| SCRP | SCRAPPED/FAILED ITEMS | N |
| SFPR | SEMI-FINISHED PRODUCTION | N |
| SFRM | SEMI-FINISHED RAW MATERIALS | N |
| SIME | SIMEDICE (CHINA) | N |
| SMPL | SAMPLES | N |
| TRIM | TRIMMING | Y |
| ZCON | CUSTOMER CONSIGNMENT STOCK | Y |

Query implications: `LIKE 'FG%'` matches `FGEN` and `FGUS`; `LIKE 'RM%'` matches none of the listed warehouses. The existing RM replenishment script therefore needs a confirmed warehouse scope before use for this company. Do not infer stock availability or MRP inclusion solely from warehouse names or bin settings.

### KB03: Item Groups

Scope: `CONTAMAC_LIVE`. Source: user-provided KB03 results, 2026-10-15. Counts are a snapshot of item master records, not stock quantities or active-item counts.

| Group number (`ItmsGrpCod`) | Group name (`ItmsGrpNam`) | Item count |
| --- | --- | ---: |
| 101 | FG - RGP | 252 |
| 102 | FG - IOL | 93 |
| 103 | FG - SIHY | 20 |
| 105 | CONSUMABLES | 115 |
| 106 | RAW MATERIALS | 225 |
| 107 | MED DEV CONSUMABLES | 95 |
| 108 | ACCESSORIES | 74 |
| 109 | FG - SOFT | 108 |
| 110 | MANUFACTURED PRODUCT | 252 |
| 111 | MED DEV RAW MATERIALS | 20 |
| 112 | SCRAP | 820 |
| 120 | PRE-MANUFACTURED | 9 |
| 121 | SEMI-FINISHED BOUGHT | 123 |
| 122 | FIXED ASSETS | 284 |
| 123 | SAMPLES | 4 |
| 125 | SEMI-FINISHED MADE | 65 |

Query implications:

- Group 100 (`To be selected`) is a placeholder, not a real business group. Exclude it from business group selections and analysis. Its 7 records appeared in the supplied export; source: user clarification, 2026-10-15.
- `LIKE 'FG%'` matches groups 101, 102, 103, and 109. It does not include group 110 (`MANUFACTURED PRODUCT`); confirm business scope before including that group.
- The FG replenishment script currently uses `LIKE 'Finished Goods%'`, which matches none of these names.
- The RM replenishment script uses `LIKE 'Raw Materials%'`; the supplied name is uppercase `RAW MATERIALS`. Use exact stored casing or confirmed group codes when adapting the filter. Group 111 is separate and needs an explicit inclusion decision.
- Preserve group names as supplied. Prefer confirmed group codes for company-specific filters when names may change; do not assume codes are shared across company schemas.

### KB04: Physical Table Inventory

Scope: `CONTAMAC_LIVE`. Source: user-provided KB04 export, 2026-10-15. Full tab-separated inventory: [docs/kb04_table_inventory.txt](docs/kb04_table_inventory.txt). Columns: `TABLE_NAME`, `TABLE_TYPE`, `COMMENTS`.

- **4,164 distinct table names**: 3,909 `COLUMN` tables and 255 `ROW` tables.
- **1,225** names begin with `@`; **785** begin with `@CT_PF_`.
- All supplied `COMMENTS` values are empty. Business meanings are not documented by this export.
- Observed naming families include `@CT_PF_`, `@CT_WMS_`, `@CT_LP_`, `@BOY_`, `@ABOY_`, and `@ZEDS`. These are naming observations, not proof of installed versions, active add-ons, or ownership.
- Use the inventory to check physical table names. It does not contain columns, view definitions, join rules, row counts, or evidence that a table is actively used. Tables without an `@` prefix are not necessarily standard SAP tables.
- Catalog visibility depends on the exporting user's permissions; treat this as the supplied snapshot rather than proof of a complete schema inventory. Use KB05 column definitions and subsequent UDF/UDO/key exports to establish structure and relationships.

### KB05: Table Column Dictionary

Scope: `CONTAMAC_LIVE`. Source: user-provided KB05 export, 2026-10-15. Full tab-separated dictionary: [docs/kb05_table_columns.txt](docs/kb05_table_columns.txt).

- **122,749 column definitions** across **4,164 tables**. The set of table names exactly matches the supplied KB04 inventory.
- Captures `TABLE_NAME`, `POSITION`, `COLUMN_NAME`, `DATA_TYPE_NAME`, `LENGTH`, `SCALE`, `IS_NULLABLE`, `DEFAULT_VALUE`, and `COMMENTS`.
- **19,101** column names begin with `U_`; **16,152** column definitions belong to tables beginning `@CT_PF_`. These are physical metadata counts, not counts of registered fields or business objects.
- Only two column comments are populated, both on `SEM_UDF_SETTING_DETAIL`; business descriptions are otherwise absent from this export.
- Before writing SQL, search this dictionary for the specific table and verify exact field names, types, nullability, and defaults. Read targeted matches rather than loading the entire dictionary into agent context; for example, `rg -n '^OITM\t' docs/kb05_table_columns.txt`.
- Column names and compatible types alone do not establish valid joins or business meanings. Use UDF descriptions, UDO registration, declared keys, and confirmed application rules as supporting evidence. Physical defaults do not necessarily describe application behavior.

### KB06: Registered User Tables

Scope: `CONTAMAC_LIVE`. Source: user-provided KB06 export, 2026-10-15. Full tab-separated registry: [docs/kb06_user_table_registry.txt](docs/kb06_user_table_registry.txt). Supplied headers: `Table Name`, `Description`.

- **751 distinct registered user tables**, all with descriptions; **402** registered names begin with `CT_PF_`.
- Registered names omit the physical `@` prefix. All 751 names map to physical tables in KB04 when prefixed with `@`; for example, `CT_PF_ABT1` maps to `@CT_PF_ABT1` (description: `Additional Batch: Properties`).
- **474** physical `@` tables in KB04 have no corresponding table-name entry in this supplied registry. PF07 subsequently identifies **472** of them as registered log-table references; the other two remain unconfirmed. Do not assume any are unused or safe to remove.
- Use registry descriptions as labels when exploring user tables, then consult KB05 for columns. Descriptions do not establish join keys, current usage, or complete business behavior. Preserve supplied names and descriptions when referencing the source.

### KB07: User-Defined Field Registry

Scope: `CONTAMAC_LIVE`. Source: user-provided KB07 export, 2026-10-15. Full tab-separated definitions: [docs/kb07_user_fields.txt](docs/kb07_user_fields.txt).

- **19,150 field definitions** across **1,370 distinct table identifiers**. Includes field titles, physical names, descriptions, type/edit settings, sizes, defaults, required-entry flags, and registered links.
- Every supplied `PhysicalColumnName` equals `U_` plus `Title`. Use `Table` and `PhysicalColumnName` together to identify a field; titles alone are not globally unique.
- **687** definitions have required-entry flag `Y`; **193** have a populated `Linked Table`. `Linked Field` and `Related UDO` are blank throughout this export. Blank registered links do not rule out application-managed relationships.
- **18,982** definitions match a table/column pair in KB05. The remaining **168** belong to `BTNT`, `BTNT1`, `OIBT`, `OSRI`, `SRNT`, and `SRNT1` (28 each). These are absent from the table-column dictionary; investigate object types and view columns before concluding fields are missing or unusable.
- The `Field` identifier is blank on **1,370** rows. Preserve these blanks as supplied; do not infer NULL or zero without a raw database check, especially before joining allowed values by table and field ID.
- Use descriptions as supporting business labels, and verify physical types against KB05. Allowed values require KB08; confirmed joins and application behavior need further evidence.

### KB08: User-Defined Field Allowed Values

Scope: `CONTAMAC_LIVE`. Source: user-provided KB08 export, 2026-10-15. Full tab-separated values: [docs/kb08_user_field_values.txt](docs/kb08_user_field_values.txt). Columns: `Table`, `Field`, `Title`, `FieldDescription`, `Index`, `Value`, `ValueDescription`.

- **6,013 allowed-value rows** for **1,537 distinct table/title combinations** across **347 table identifiers**.
- All table/title combinations exist in KB07, and supplied field identifiers match, including blanks preserved by both exports. This consistency check does not resolve the meaning of blank identifiers.
- Use `Value` as the stored code and `ValueDescription` as its label; `Index` is not the stored business value. For example, `@ACT_CW_OBTN.U_Status` maps `0` to `Close`, `1` to `Open`, `2` to `Production`, `3` to `PickAndPack`, and `4` to `Counting`. Do not apply this mapping to other status fields without checking their definitions.
- Preserve codes as text in the reference data, including leading zeros and case; use KB05 physical types when writing SQL. Scope lookups by table and field, not by value or title alone.
- There are **149** rows with blank field IDs, **1,412** with blank indices, **42** with blank values, and **139** with blank value descriptions. Preserve blanks as supplied; do not reinterpret them as NULL, zero, or invalid entries without database verification.
- A field absent from KB08 may use free text, a linked table, or application validation. This export alone does not define its permitted inputs or prove which values occur in business records.

### KB09: UDO Parent & Child Table Registration

Scope: `CONTAMAC_LIVE`. Source: user-provided KB09 export, 2026-10-15. Full tab-separated registrations: [docs/kb09_udo_tables.txt](docs/kb09_udo_tables.txt). Columns: `UDOCode`, `UDOName`, `RegisteredParentTable`, `ChildNumber`, `RegisteredChildTable`.

- **417 export rows** describe **212 distinct UDOs**, with **212 parent tables** and **294 distinct child tables**. **123 UDOs** have no child table listed; the other **89** have child registrations.
- **150** parent table names begin with `CT_PF_`.
- All **506 distinct parent/child table names** occur in KB06 and map to physical tables in KB04 after adding `@`.
- This export establishes registered table membership, not join columns or cardinality in business records. `ChildNumber` is registration metadata, not a business-record join key; all rows with a child table have a populated child number in this export.
- Repeated UDO rows represent child memberships, not additional UDOs. For example, `BOY_41_FUNCTIONS` registers child tables such as `BOY_41_FUNC_L01` and `BOY_41_FUNC_L02`.
- Before joining parent and child data, verify columns in KB05 and keys in KB10/KB11 when provided, plus application rules. Do not assume every UDO joins on `DocEntry`; registration alone does not distinguish all key patterns or document application-managed relationships.

### KB10: Declared Keys & Constraints

Scope: `CONTAMAC_LIVE`. Source: user-provided KB10 export, 2026-10-15. Full tab-separated constraints: [docs/kb10_constraints.txt](docs/kb10_constraints.txt).

- **9,674 column-level rows** describe **4,908 distinct table/constraint combinations** across **3,894 tables**: **3,894 primary keys** and **1,014 additional unique constraints**.
- **3,006 constraints** are composite, including **2,612 primary keys**. Reconstruct each constraint by grouping `TABLE_NAME` and `CONSTRAINT_NAME`, then ordering columns numerically by `POSITION`.
- All referenced tables match KB04 and all referenced columns match KB05. The other **270 KB04 tables** have no constraints listed in this export; do not infer their uniqueness rules from this absence alone.
- `CHECK_CONDITION` is blank throughout this export; it does not document application-level validation.
- Example: the supplied `OITW` primary key is (`ItemCode`, `WhsCode`), in that order. `ItemCode` alone does not uniquely identify an item/warehouse record. Match the intended result granularity when joining or aggregating.
- Declared keys establish uniqueness, not relationships between tables. Use KB11 foreign keys when provided and confirmed application rules to establish joins. Do not assume system-generated constraint names are stable across company schemas or database copies.

### KB11: Declared Foreign Keys

Scope: `CONTAMAC_LIVE`. Source: user-reported KB11 query result, 2026-10-15: **no records returned**.

- No declared foreign keys were returned by the query for relationships touching the current company schema, within the exporting user's catalog visibility.
- This does not prove that tables have no relationships. Application-managed relationships may exist without database foreign-key constraints; permissions may also limit visible metadata.
- Establish joins using KB05 columns, KB07 registered field links, KB09 UDO membership, KB10 keys, and confirmed application rules. Validate join cardinality and totals against SAP before relying on a relationship.

### KB12: View Inventory

Scope: `CONTAMAC_LIVE`. Source: user-provided KB12 export, 2026-10-15. Full tab-separated names: [docs/kb12_views.txt](docs/kb12_views.txt).

- **469 distinct view names**, including **79** beginning `B1_` and **136** beginning `JG_`. Prefixes alone do not establish ownership, purpose, or current usage.
- Preserve exact case: both `JG_BusinessSplitByPeriod_Detailed_LastYear_V2` and `JG_BusinessSplitByPeriod_Detailed_LastYear_v2` are listed. Case-insensitive deduplication would incorrectly merge these names.
- `OIBT` and `OSRI`, whose KB07 field definitions did not match the table-only KB05 dictionary, are listed as views. Their view columns still need verification. `BTNT`, `BTNT1`, `SRNT`, and `SRNT1` are not listed in this view snapshot; their object status remains unconfirmed.
- `JG_MonthlyStockReport_SemiFinishedOnly_v4_ByItem` is listed, matching the view name in the repository's monthly stock report script. Presence does not prove the deployed SQL matches the local file.
- This export contains names only, not view columns, SQL definitions, dependencies, or result granularity. Verify those before using a view as a trusted reporting source; suffixes such as `TEST`, `OLD`, or version numbers alone do not identify the approved version.

### KB13: Units of Measure

Scope: `CONTAMAC_LIVE`. Source: user-provided KB13 results, 2026-10-15. Full tab-separated directory: [docs/kb13_units.txt](docs/kb13_units.txt).

- **181 UoM entries**, each with a distinct absolute entry ID. Supplied headers map to `OUOM.UomEntry`, `OUOM.UomCode`, and `OUOM.UomName`.
- Entry **-1** is labelled `Manual`; entry **175** is `Each`. Preserve these identifiers and do not assume the same mappings in other company schemas.
- Preserve exact codes, display names, case, and spacing. Examples: entry 155 is `1 L`, while entry 160 is `1L`; entry 285 has code `10kg` and name `10Kg`; entry 306 has code `FOC Contract` and name `Contract (FOC)`.
- Similar names do not prove equivalent units or interchangeable IDs. For example, `Pack2` (320), `Pack 2` (321), and `pack of 2` (266) are separate entries.
- UoM names alone do not establish pack sizes, conversion factors, inventory units, or actual item usage. Use KB14 group conversions and item/document settings before calculating quantities; do not infer conversions from numbers embedded in names.

### KB14: UoM Groups & Conversion Factors

Scope: `CONTAMAC_LIVE`. Source: user-provided KB14 export, 2026-10-15. Full tab-separated groups and factors: [docs/kb14_uom_groups.txt](docs/kb14_uom_groups.txt).

- **833 group-detail rows** across **75 UoM groups**, referencing **162 distinct UoM entries**. All supplied detail/base UoM IDs and codes match KB13 exactly. Every supplied alternative and base quantity is positive.
- Examples: group 29 (`Volume`) has base `ml` (177); group 33 (`Each`) has base `Each` (175); group 34 (`Mass`) has base `Grams` (176). Group -1 is `Manual` with a supplied 1:1 row; this does not establish item-specific manual conversions.
- Read each exported ratio as `Alternative Quantity` of the row's UoM corresponding to `Base Quantity` of the group's base UoM. Example: group 29 records 1 `1 L` (155) as 1,000 `ml` (177). For that group ratio, base quantity = alternative-UoM quantity × `Base Quantity` / `Alternative Quantity`.
- Scope conversions by group and UoM entry, not UoM code alone. Confirm the item's assigned group, inventory UoM, item-specific overrides, and document settings before applying factors. A group's base UoM is not automatically every assigned item's inventory UoM.
- Preserve the original numeric text; it uses commas as thousands separators and periods as decimal separators (for example, `1,000.0000`). Parse using that convention before calculations.
- The export records configuration, not item assignments, current usage, or document-level conversion history. KB13 entries absent from these rows are not necessarily unused.

### KB15: Item Configuration Profiles

Scope: `CONTAMAC_LIVE`. Source: user-provided KB15 table, 2026-10-15. Full tab-separated profiles: [docs/kb15_item_profiles.txt](docs/kb15_item_profiles.txt). Supplied rows and displayed blanks are preserved, including rows that appear identical.

- **79 profile rows** account for **2,566 item records**; totals for every group reconcile with KB03. Excluding placeholder group 100 gives **2,559 items across 16 business groups**. Group 100 is retained only in the source snapshot and excluded from business analysis.
- Counts describe item master configuration, not stock, activity, or approved planning policy. No supplied profile has serial management `Y`.
- Groups 101, 102, 103, and 109 have stock/sales flags `Y`, purchasing flag `N`, batch management `Y`, and valuation code `B` throughout. Their planning/procurement combinations vary; do not assume all FG items share one planning setup.
- Group 106 has batch management `Y` and valuation `B` throughout; group 111 instead has batch management `N` and valuation `A` throughout. Do not apply one raw-material valuation assumption to both groups.
- Group 125 (`SEMI-FINISHED MADE`) has planning `M` and procurement `B` for all 65 items. Group 121 (`SEMI-FINISHED BOUGHT`) contains one item with procurement `M`. Preserve actual configuration and confirm intent rather than deriving settings from group names.
- Stock UoM is displayed blank for **564 business-group items**. Case variants include `Each`/`each`/`EACH` and `Rod`/`rod`/`ROD`; preserve these strings and do not infer UoM entry IDs from them. Displayed blanks may conceal NULL/empty/whitespace distinctions; do not merge apparently duplicate profiles without checking the source values.
- Valuation, planning, and procurement codes belong to different fields; interpret each against its field definition. Item-level identifiers, UoM group assignments, and application rules are needed before changing configuration or applying conversions.

### KB16: Warehouse Min/Max Configuration Coverage

Scope: `CONTAMAC_LIVE`. Source: user-provided KB16 export, 2026-10-15. Full tab-separated summary: [docs/kb16_warehouse_minmax.txt](docs/kb16_warehouse_minmax.txt).

- **360 warehouse/group rows** cover all **24 KB02 warehouses** and **15 groups**, including placeholder 100. Excluding group 100 leaves **336 rows**, representing **49,824 inventory-item/warehouse records**, not distinct items or stock quantities. Warehouse and group names match KB02/KB15.
- Supplied nonblank business-group counts sum to **196 records with positive minima**, **196 with positive maxima**, and **3 with maximum below minimum**. Blank counters are preserved as displayed and need raw verification before being treated as zero.
- Positive minima are displayed only in `FGEN` and `FGUS`; positive maxima are also displayed for 3 `SMPL` records in group 108. This is configuration coverage, not an approved replenishment scope.
- `FGEN`, group **108 (`ACCESSORIES`)**, reports **8** records with positive minima, **5** with positive maxima, and **3** with maximum below minimum. Identify and review the individual items before relying on min/max replenishment; this aggregate does not identify them.
- Groups 122 (`FIXED ASSETS`) and 123 (`SAMPLES`) have no rows in this inventory-item-only export. Do not confuse item group 123 with warehouse `SMPL`.
- Counts cannot establish current shortages, stock availability, per-item min/max quantities, or whether warehouse records refer to active items. Do not sum quantities across items with different units, or infer that equal minimum/maximum coverage counts refer to the same item set.

### KB17: Item Purchasing & Sales Unit Profiles

Scope: `CONTAMAC_LIVE`. Source: user-provided KB17 table, 2026-10-15. Full tab-separated profiles: [docs/kb17_item_unit_profiles.txt](docs/kb17_item_unit_profiles.txt). Displayed blanks, repeated-looking rows, case, and numeric text are preserved.

- **108 profile rows** account for **2,566 items**. Totals by exact-case stock UoM reconcile with KB15, including **571** items with displayed blank stock UoM. This unfiltered snapshot includes group 100; KB17 has no group column, so its contributions cannot be isolated within individual profiles without further evidence.
- **44 items** have a supplied purchasing factor other than 1. Examples include `Each`/`Tray 186` with factor 186 and `g`/`0.5g` with factor 0.5. These are item configuration profiles, not universal conversion rules for a UoM name.
- Similar purchasing labels have different supplied factors: `500g tub` with blank stock UoM appears with factors 1, 500, and 1,000. Preserve these differences and investigate individual items before treating them as errors or standardizing them.
- One item has stock UoM `g`, purchasing UoM `g`, purchasing factor 1, sales UoM `Drum`, and sales factor displayed as **`########`**. Its numeric sales factor is unknown; obtain the untruncated database value before using it in calculations. Do not replace it with zero or infer it from the label.
- The source fields correspond to `OITM.InvntryUom`, `BuyUnitMsr`, `NumInBuy`, `SalUnitMsr`, and `NumInSale`. These text labels do not establish UoM entry IDs or group assignments. Use actual item/document conversion settings and quantity units when reconciling transactions.
- Parse comma-grouped numbers using the supplied numeric convention, preserve fractional precision, and verify blank versus NULL/whitespace distinctions before merging apparently identical rows. Exclude group 100 explicitly in future item-level business analyses.

### PF01: ProcessForce Physical Table Inventory

Scope: `CONTAMAC_LIVE`, explicitly present on every supplied row. Source: user-provided ProcessForce export 01, 2026-10-15. Full tab-separated inventory: [docs/pf01_tables.txt](docs/pf01_tables.txt).

- **785 distinct `@CT_PF_` tables**, all with `TABLE_TYPE` = `COLUMN`. The table-name set exactly matches the `@CT_PF_` subset of KB04.
- Supplied columns are `SCHEMA_NAME`, `TABLE_NAME`, and `TABLE_TYPE`; no comments or business descriptions were supplied in this export.
- Use PF01 for ProcessForce table-name discovery, KB05 for physical columns, KB06 for available registered descriptions, and KB09 for UDO membership. Table presence alone does not establish current usage, add-on version, or valid joins. Further ProcessForce exports should retain their own PF section numbers to distinguish them from the general KB series.

### PF02: ProcessForce Table Column Dictionary

Scope: `CONTAMAC_LIVE`, explicitly present on every supplied row. Source: user-provided ProcessForce export 02, 2026-10-15. Full tab-separated definitions: [docs/pf02_table_columns.txt](docs/pf02_table_columns.txt).

- **16,152 column definitions** cover all **785 PF01 tables**, including **10,013** column names beginning `U_`.
- All supplied table/column definitions, positions, types, lengths, scales, nullability, defaults, and comments exactly match the ProcessForce subset of KB05. No populated column comments were supplied.
- Use this focused dictionary to verify ProcessForce field names and physical types before writing queries. Search specific tables rather than loading the entire file into agent context; for example, `rg -n '^CONTAMAC_LIVE\t@CT_PF_AABT\t' docs/pf02_table_columns.txt`.
- Presence of fields such as `Code` or `DocEntry` does not establish a key or join rule. Combine column evidence with KB07/KB08 descriptions and allowed values, KB09 registration, and declared keys before validating relationships against application behavior.

### PF03: ProcessForce Declared Keys & Constraints

Scope: `CONTAMAC_LIVE`, explicitly present on every supplied row. Source: user-provided ProcessForce export 03, 2026-10-15. Full tab-separated constraints: [docs/pf03_constraints.txt](docs/pf03_constraints.txt).

- **2,012 column-level rows** describe **1,039 constraints** across **783 tables**: **783 primary keys** and **256 additional unique constraints**.
- **676 constraints** are composite, including **620 primary keys**. Group by table and constraint name, then order columns numerically by `POSITION`; retain every component when identifying unique records.
- All supplied constraints exactly match the ProcessForce subset of KB10, and every referenced column exists in PF02. Two PF01 tables have no constraints listed in this export; absence alone does not establish their uniqueness rules.
- `CHECK_CONDITION` is blank throughout. This export does not document application-level validation or foreign-key relationships.
- Example: `@CT_PF_AABT` has primary key (`Code`, `LogInst`). `Code` alone is not its declared unique record identifier. Do not infer a parent/child join from shared column names or omit version/history key components without confirming the intended record scope.

### PF04: ProcessForce Declared Foreign Keys

Scope: `CONTAMAC_LIVE`. Source: user-reported ProcessForce export 04 query result, 2026-10-15: **zero records returned**.

- No declared foreign keys involving `@CT_PF_` tables were returned within the executing user's catalog visibility. This is consistent with the empty general KB11 result.
- Application-managed ProcessForce relationships may exist without declared database foreign keys. Establish joins using column definitions, UDO registrations, declared keys, and confirmed application rules; validate cardinality and report totals before relying on them.

### PF05: ProcessForce UDO Table Registration

Scope: `CONTAMAC_LIVE`. Source: user-provided ProcessForce export 05, 2026-10-15. Full tab-separated registrations: [docs/pf05_udo_tables.txt](docs/pf05_udo_tables.txt).

- **322 export rows** describe **150 distinct UDOs**, with **150 parent tables** and **239 distinct child tables**. **83 UDOs** have no child table listed; the other **67** have child registrations.
- Every supplied registration exactly matches the ProcessForce subset of KB09. All **389 distinct parent/child table names** map to PF01 physical tables after adding `@`.
- Preserve exact UDO codes separately from UDO names and table names. For example, `CT_PF_AdditonalBatch` registers parent `CT_PF_OABT` and children `CT_PF_ABT1` and `CT_PF_ABT6`; the supplied spelling of the UDO code is intentional in this reference.
- Use this export to identify registered table membership. `ChildNumber` does not define a record join, and repeated UDO rows represent child registrations. Establish key columns and record scope using PF02/PF03 and confirmed application rules; PF04 returned no declared foreign-key evidence.

### PF06: ProcessForce & CT User-Defined Fields

Scope: `CONTAMAC_LIVE`. Source: user-provided ProcessForce export 06, 2026-10-15. Full tab-separated definitions: [docs/pf06_user_fields.txt](docs/pf06_user_fields.txt).

- **9,969 field definitions** across **784 table identifiers**: **9,965** definitions on `@CT_PF_` tables plus **4** `CT_` fields on other tables. The latter are included by the export filter, not proof of ProcessForce ownership.
- Every supplied definition exactly matches the corresponding filtered KB07 subset. All table/physical-column pairs exist in KB05; use PF02 for the physical definitions on ProcessForce tables.
- **2** definitions have required-entry flag `Y`, and **6** have a populated linked table. Linked-field and related-UDO values are blank throughout; application-managed relationships may still exist.
- **784** rows have displayed blank field IDs. Preserve these as supplied and verify raw values before joining allowed-value metadata by table and field ID. Use exact physical names and table scope rather than assuming titles are globally unique.
- Version-related field definitions such as `U_PFVersion` and `U_PFDBVersion` describe available columns, not the installed ProcessForce version. Confirm actual version evidence separately. Use KB08 for available registered values and PF05/PF03 for membership and key evidence.

### PF07: Full User-Table Registry Metadata

Scope: `CONTAMAC_LIVE`. Source: user-provided ProcessForce export 07, 2026-10-15. Full tab-separated registry: [docs/pf07_user_table_registry.txt](docs/pf07_user_table_registry.txt). This section covers all registered user tables, not only ProcessForce.

- **751 entries**; table names and descriptions exactly match KB06. Additional columns capture table number, object type, used-in object, log table, archiving, display-menu, and authorization flags.
- **506 entries** have populated `Used in Object` values referencing **212 distinct UDO codes**, all present in KB09. These references complement table membership; they do not define record join columns.
- **472 entries** reference **472 distinct log tables**, all present in KB04 after adding `@`. None of these log tables appears as its own table-name entry in KB06. This explains 472 of the 474 physical `@` tables absent from that registry's table-name list. The remaining two are `@CT_PF_AMOR5_OLD` and `@CT_PF_MOR5_OLD`; neither has constraints listed in PF03. Their purpose and current usage remain unconfirmed.
- Example: `CT_PF_OABT` references object `CT_PF_AdditonalBatch` and log table `CT_PF_AABT`. Use explicit log metadata rather than inferring history-table roles from naming alone; confirm history/version keys before combining records.
- Raw object-type counts: `0`: 204, `1`: 177, `2`: 233, `3`: 43, `4`: 83, `5`: 11. Preserve these codes and verify their definitions before interpreting them.
- Every row has `Archivable` = `N`, `Display Menu` = `Y`, and `Apply Authorisation` = `N`. These are registry flags, not a complete statement of effective user permissions or application behavior.

### KB18: CompuTec Products & Workflow References

Scope: the user confirms use of **ProcessForce, WMS, PDC, Labels, and AppEngine**, 2026-10-15. Company facts remain scoped to `CONTAMAC_LIVE` unless explicitly stated otherwise. User-confirmed versions on that date:

| Product | Installed version |
| --- | --- |
| ProcessForce | CompuTec ProcessForce 10.0, build **10.0.20.15**, **Release 20 HF 2**, **64-bit** |
| WMS | **2.10.20.10** |
| PDC | **3.10.18.2** |
| Labels | **4.7.1.117** |
| AppEngine | **2.10.11.5** |

Use the **ProcessForce 2.0 documentation branch** for the confirmed 10.0 R20 HF2 generation; the [vendor release listing](https://learn.computec.one/docs/processforce/2.0/releases/download/) explicitly lists build 10.0.20.15. Use the **AppEngine 2.0 documentation branch** for confirmed build 2.10.11.5. PDC's 3.x version does **not** establish AppEngine 3.0: [PDC build 3.10.18.2 is listed under AppEngine 2.0 plugins](https://learn.computec.one/pl/docs/appengine/2.0/releases/plugins/pdc/download/). Enabled company settings remain unconfirmed. Treat the guides' ProcessForce/WMS/AppEngine 3.0 deployment material as separate reference, not the current installation baseline. Labels features documented as starting in 4.8.9, such as structured per-request process logs, do not apply to the confirmed 4.7.1.117 build.

Vendor knowledge reviewed from [CompuTec Learn](https://learn.computec.one/) on 2026-10-15:

- [Index and integration map](docs/computec/README.md): product roles, documentation versions, and investigation rules.
- [ProcessForce](docs/computec/processforce.md): manufacturing definitions, MOR lifecycle, time/corrections, costing, QC, and local schema anchors.
- [WMS](docs/computec/wms.md): warehouse and production transactions, storage units, bins, UoM, and deployment boundaries.
- [PDC](docs/computec/pdc.md): tasks, time/quantity registration, downtime, resource counts, and repeated-booking investigation.
- [Labels](docs/computec/labels.md): rules, parameter mapping, requests, logs, plugin viewing, and reprints.
- [AppEngine](docs/computec/appengine.md): instances, company/plugin assignments, jobs/triggers, runtime boundaries, and diagnostics.

Read only the relevant topic and metadata matches for a task. Vendor documentation does not establish local adoption, approved join rules, or effective settings. Confirm the installed generation before applying configuration/API examples, and retain source links and review dates when updating these references.

### KB19: Boyum B1UP Environment Baseline

Scope: **Contamac Ltd (`CONTAMAC_LIVE`)**. Source: user-provided SAP/B1UP System Information, **2026-10-21**. Detailed settings: [docs/boyum/README.md](docs/boyum/README.md).

- Installed add-on: **B1 Usability Package 2023.06**; Server Component: **2023.6.0.0**.
- SAP version reported as **1000201 (1000201)**; preserve the raw identifier rather than inferring a feature pack. Database: **HANA**; access mode: **Hana (Lazy DI-API)**, access check **OK**.
- Localization **GB**, local/system currencies **GBP/GBP**, culture/UI culture **en-GB**, dates **dd/MM/yyyy**, times **HH:mm**.
- Reported license: **Enterprise**, **55 users**, valid at capture through **01/01/2027**, maximum allowed version **2026.10.***. The licensed maximum is not the installed version.
- Active B1UP module codes: `FB`, `IPT`, `MF`, `A&EM`, `TOOL`, `MIRO`, `ER`, `B1VAL`, `MDM`, `B1P&D`.
- Inactive B1UP module codes: `DD`, `QC`, `TS`, `TC`, `RCMC`, `LM`, `B1S`, `PLD`, `RI`, `B1D`, `BEAS`, `B1MC`. Do not interpret these as flags for separate CompuTec products.
- Preserve codes until their release-specific display names are verified. Custom UF definitions, validation triggers, macros, SQL reports, Dynamic Code, schedules, and other configuration contents are not yet inventoried; existing table/field metadata alone does not establish their behavior.
