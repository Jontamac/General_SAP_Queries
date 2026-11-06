/*
    SAP Business One on HANA: ProcessForce metadata export (read-only).

    Run each numbered SELECT separately in SAP B1 Query Manager, or run the
    script in a HANA SQL console that supports multiple result sets.
    Export each result to CSV with column headers, using the suggested names.

    IMPORTANT: the connection's CURRENT_SCHEMA must be your SAP B1 company
    schema, not SYSTEM or a different company. Check section 0 first.
    In a SQL console, select your company schema before running this script.
    All SYS catalog queries below are limited to CURRENT_SCHEMA.

    Scope: tables beginning @CT_PF_, and CT_ user fields on other tables.
    This discovers objects visible to the executing database user. An empty
    result can reflect permissions or a different naming convention.
    Section 7 inventories all registered user tables to help find other names.

    Database keys, UDO parent/child registration, and UDF links are evidence
    for relationships, not a complete ProcessForce join specification.
    Application-managed joins may have no declared foreign key. Do not infer
    a join solely because two columns have the same name. Composite keys
    require every participating column in the correct order.

    No business transaction rows are exported or changed.

    References:
    https://help.sap.com/docs/SAP_HANA_PLATFORM/4fe29514fd584807ac9f2a04f6754767/2100d33a75191014868bbcd89274199c.html
    https://help.sap.com/docs/SAP_HANA_PLATFORM/4fe29514fd584807ac9f2a04f6754767/209f7cf5751910149d9ce6b033d8ddce.html
    https://help.sap.com/docs/SAP_HANA_PLATFORM/4fe29514fd584807ac9f2a04f6754767/20ccc0a175191014901b88e6bc175c44.html
    https://help.sap.com/doc/089315d8d0f8475a9fc84fb919b501a3/10.0/en-US/SDKHelp/CUFD.html
    https://help.sap.com/doc/089315d8d0f8475a9fc84fb919b501a3/10.0/en-US/SDKhelp/OUDO.html
    https://help.sap.com/doc/089315d8d0f8475a9fc84fb919b501a3/10.0/en-US/SDKhelp/UDO1.html
*/

-- 0. Verify the company schema before continuing: 00_context.csv
SELECT CURRENT_SCHEMA AS "CompanySchema", CURRENT_USER AS "DatabaseUser"
FROM DUMMY;

-- 1. ProcessForce tables: 01_pf_tables.csv
SELECT T."SCHEMA_NAME", T."TABLE_NAME", T."TABLE_TYPE", T."COMMENTS"
FROM "SYS"."TABLES" T
WHERE T."SCHEMA_NAME" = CURRENT_SCHEMA
  AND LEFT(T."TABLE_NAME", 7) = '@CT_PF_'
ORDER BY T."TABLE_NAME";

-- 2. Full ProcessForce column definitions: 02_pf_columns.csv
SELECT C."SCHEMA_NAME", C."TABLE_NAME", C."POSITION", C."COLUMN_NAME",
       C."DATA_TYPE_NAME", C."LENGTH", C."SCALE", C."IS_NULLABLE",
       C."DEFAULT_VALUE", C."COMMENTS"
FROM "SYS"."TABLE_COLUMNS" C
WHERE C."SCHEMA_NAME" = CURRENT_SCHEMA
  AND LEFT(C."TABLE_NAME", 7) = '@CT_PF_'
ORDER BY C."TABLE_NAME", C."POSITION";

-- 3. Declared primary/unique keys and other constraints: 03_pf_constraints.csv
SELECT K."SCHEMA_NAME", K."TABLE_NAME", K."CONSTRAINT_NAME",
       K."POSITION", K."COLUMN_NAME", K."IS_PRIMARY_KEY",
       K."IS_UNIQUE_KEY", K."CHECK_CONDITION"
FROM "SYS"."CONSTRAINTS" K
WHERE K."SCHEMA_NAME" = CURRENT_SCHEMA
  AND LEFT(K."TABLE_NAME", 7) = '@CT_PF_'
ORDER BY K."TABLE_NAME", K."CONSTRAINT_NAME", K."POSITION";

-- 4. Declared foreign keys involving ProcessForce: 04_pf_foreign_keys.csv
-- An empty result does not mean that there are no application relationships.
SELECT R.*
FROM "SYS"."REFERENTIAL_CONSTRAINTS" R
WHERE (R."SCHEMA_NAME" = CURRENT_SCHEMA
       AND LEFT(R."TABLE_NAME", 7) = '@CT_PF_')
   OR (R."REFERENCED_SCHEMA_NAME" = CURRENT_SCHEMA
       AND LEFT(R."REFERENCED_TABLE_NAME", 7) = '@CT_PF_')
ORDER BY R."SCHEMA_NAME", R."TABLE_NAME", R."CONSTRAINT_NAME", R."POSITION";

-- 5. Registered ProcessForce UDO parents and children: 05_pf_udo_tables.csv
-- B1 registration normally stores UDT names without the physical @ prefix.
-- Registration identifies table membership; it does not specify join columns.
SELECT H."Code" AS "UDOCode", H."Name" AS "UDOName",
       H."TableName" AS "RegisteredParentTable",
       C."SonNum" AS "ChildNumber", C."TableName" AS "RegisteredChildTable"
FROM "OUDO" H
LEFT JOIN "UDO1" C ON C."Code" = H."Code"
WHERE LEFT(H."TableName", 6) = 'CT_PF_'
   OR LEFT(H."TableName", 7) = '@CT_PF_'
   OR LEFT(C."TableName", 6) = 'CT_PF_'
   OR LEFT(C."TableName", 7) = '@CT_PF_'
ORDER BY H."Code", C."SonNum";

-- 6. UDF descriptions and registered links: 06_pf_and_ct_user_fields.csv
-- Includes every UDF on ProcessForce tables plus CT_ UDFs on other tables.
-- CT_ fields outside PF tables may belong to other CompuTec products.
SELECT F."TableID", F."FieldID", F."AliasID",
       'U_' || F."AliasID" AS "PhysicalColumnName",
       F."Descr", F."TypeID", F."EditType", F."SizeID", F."EditSize",
       F."Dflt", F."NotNull", F."RTable", F."RField", F."RelUDO"
FROM "CUFD" F
WHERE LEFT(F."TableID", 7) = '@CT_PF_'
   OR LEFT(F."TableID", 6) = 'CT_PF_'
   OR LEFT(F."AliasID", 3) = 'CT_'
ORDER BY F."TableID", F."FieldID";

-- 7. All registered user tables for naming discovery: 07_user_table_registry.csv
SELECT T.*
FROM "OUTB" T
ORDER BY T."TableName";
