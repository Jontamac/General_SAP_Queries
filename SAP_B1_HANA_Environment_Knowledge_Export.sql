/*
    SAP Business One / SAP HANA: environment knowledge export (read-only).

    HOW TO RUN
    1. Connect to the intended company schema, preferably a test copy.
    2. Run section 00 and confirm the schema before continuing.
    3. Run each numbered SELECT separately in B1 Query Manager, or use a
       HANA SQL console supporting multiple result sets.
    4. Export each result with column headers using the suggested filename.
       Keep the files together with the extraction date and environment label.
    5. Also run SAP_B1_HANA_ProcessForce_Schema_Export.sql for PF-specific detail.

    Scope: configuration, metadata, and aggregate item/warehouse profiles.
    No customer/supplier records, transaction rows, passwords, or stock values.
    Names, defaults, and custom metadata can still contain internal information;
    review exports before sharing and keep raw exports outside Git.

    All catalog queries are restricted to CURRENT_SCHEMA. Results reflect the
    executing user's visibility: missing rows do not prove objects are absent.
    Queries target SAP B1 10.0 field names; older versions/localizations may differ.
    If a field is unavailable, use section 05 to inspect its table definition.
    No statements here create or change database objects.

    INTERPRETATION
    - Profiles count configured records, including inactive/frozen items.
    - Do not infer business meanings from warehouse/item-group names alone.
    - UDO membership and declared keys do not fully document application joins.
    - UDF links may be empty even when application-managed relationships exist.
    - Standard B1 BOM settings do not describe the full ProcessForce model.

    RECORD MANUALLY
    SAP B1 client version/feature pack/patch (Help > About), HANA revision,
    installed add-on versions, integrations, production/test schema mapping,
    warehouse purposes, item-group rules, UDF meanings, approved join rules,
    and validation owners. OADM version numbers below are raw database values,
    not a complete installed-software inventory.
    Mark knowledge as verified/assumed/unconfirmed with source and date.

    References (SAP B1 SDK 10.0 database tables):
    https://help.sap.com/doc/089315d8d0f8475a9fc84fb919b501a3/10.0/en-US/SDKHelp/oadm.html
    https://help.sap.com/doc/089315d8d0f8475a9fc84fb919b501a3/10.0/en-US/SDKHelp/OITM.html
    https://help.sap.com/doc/089315d8d0f8475a9fc84fb919b501a3/10.0/en-US/SDKHelp/OWHS.html
    https://help.sap.com/doc/089315d8d0f8475a9fc84fb919b501a3/10.0/en-US/SDKhelp/UFD1.html
*/

-- 00. Connection context: kb_00_context.csv
SELECT CURRENT_SCHEMA AS "CompanySchema", CURRENT_USER AS "DatabaseUser",
       CURRENT_UTCTIMESTAMP AS "ExtractedAtUTC"
FROM DUMMY;

-- 01. Selected company settings: kb_01_company.csv
-- Deliberately excludes addresses, tax IDs, contacts, paths, and bank details.
SELECT "CompnyName", "Country", "MainCurncy", "SysCurrncy",
       "DbVers", "ApplVers"
FROM "OADM";

-- 02. Warehouse directory: kb_02_warehouses.csv
SELECT "WhsCode", "WhsName", "BinActivat"
FROM "OWHS"
ORDER BY "WhsCode";

-- 03. Item groups, including groups with no items: kb_03_item_groups.csv
SELECT G."ItmsGrpCod", G."ItmsGrpNam", COUNT(I."ItemCode") AS "ItemCount"
FROM "OITB" G
LEFT JOIN "OITM" I ON I."ItmsGrpCod" = G."ItmsGrpCod"
GROUP BY G."ItmsGrpCod", G."ItmsGrpNam"
ORDER BY G."ItmsGrpCod";

-- 04. Physical table inventory: kb_04_tables.csv
SELECT "TABLE_NAME", "TABLE_TYPE", "COMMENTS"
FROM "SYS"."TABLES"
WHERE "SCHEMA_NAME" = CURRENT_SCHEMA
ORDER BY "TABLE_NAME";

-- 05. Table column dictionary: kb_05_table_columns.csv
-- Potentially large; metadata only. Filter TABLE_NAME if exports are limited.
SELECT "TABLE_NAME", "POSITION", "COLUMN_NAME", "DATA_TYPE_NAME",
       "LENGTH", "SCALE", "IS_NULLABLE", "DEFAULT_VALUE", "COMMENTS"
FROM "SYS"."TABLE_COLUMNS"
WHERE "SCHEMA_NAME" = CURRENT_SCHEMA
ORDER BY "TABLE_NAME", "POSITION";

-- 06. Registered user tables: kb_06_user_tables.csv
-- Registry TableName normally omits the physical @ prefix.
SELECT "TableName", "Descr"
FROM "OUTB"
ORDER BY "TableName";

-- 07. All UDF definitions and registered links: kb_07_user_fields.csv
SELECT "TableID", "FieldID", "AliasID",
       'U_' || "AliasID" AS "PhysicalColumnName",
       "Descr", "TypeID", "EditType", "SizeID", "EditSize",
       "Dflt", "NotNull", "RTable", "RField", "RelUDO"
FROM "CUFD"
ORDER BY "TableID", "FieldID";

-- 08. UDF allowed values and descriptions: kb_08_user_field_values.csv
-- FieldID is unique only within TableID; both columns are required for the join.
SELECT F."TableID", F."FieldID", F."AliasID", F."Descr" AS "FieldDescription",
       V."IndexID", V."FldValue", V."Descr" AS "ValueDescription"
FROM "CUFD" F
INNER JOIN "UFD1" V
    ON V."TableID" = F."TableID" AND V."FieldID" = F."FieldID"
ORDER BY F."TableID", F."FieldID", V."IndexID";

-- 09. UDO parent/child registration: kb_09_udo_tables.csv
-- This is table membership, not a specification of join columns.
SELECT H."Code" AS "UDOCode", H."Name" AS "UDOName",
       H."TableName" AS "RegisteredParentTable",
       C."SonNum" AS "ChildNumber", C."TableName" AS "RegisteredChildTable"
FROM "OUDO" H
LEFT JOIN "UDO1" C ON C."Code" = H."Code"
ORDER BY H."Code", C."SonNum";

-- 10. Declared keys and constraints: kb_10_constraints.csv
-- Preserve POSITION when reconstructing composite keys.
SELECT "TABLE_NAME", "CONSTRAINT_NAME", "POSITION", "COLUMN_NAME",
       "IS_PRIMARY_KEY", "IS_UNIQUE_KEY", "CHECK_CONDITION"
FROM "SYS"."CONSTRAINTS"
WHERE "SCHEMA_NAME" = CURRENT_SCHEMA
ORDER BY "TABLE_NAME", "CONSTRAINT_NAME", "POSITION";

-- 11. Declared foreign keys touching this schema: kb_11_foreign_keys.csv
-- Empty output does not imply that application relationships are absent.
SELECT R.*
FROM "SYS"."REFERENTIAL_CONSTRAINTS" R
WHERE R."SCHEMA_NAME" = CURRENT_SCHEMA
   OR R."REFERENCED_SCHEMA_NAME" = CURRENT_SCHEMA
ORDER BY R."SCHEMA_NAME", R."TABLE_NAME", R."CONSTRAINT_NAME", R."POSITION";

-- 12. View inventory (no SQL definitions): kb_12_views.csv
SELECT "VIEW_NAME"
FROM "SYS"."VIEWS"
WHERE "SCHEMA_NAME" = CURRENT_SCHEMA
ORDER BY "VIEW_NAME";

-- 13. Units of measure: kb_13_units.csv
SELECT "UomEntry", "UomCode", "UomName"
FROM "OUOM"
ORDER BY "UomEntry";

-- 14. UoM groups and conversion ratios: kb_14_uom_groups.csv
-- Keep raw factors: interpretation may also depend on item-specific settings.
SELECT G."UgpEntry", G."UgpCode", G."UgpName", G."BaseUom",
       B."UomCode" AS "BaseUomCode", D."LineNum", D."UomEntry",
       U."UomCode", D."AltQty", D."BaseQty"
FROM "OUGP" G
LEFT JOIN "OUOM" B ON B."UomEntry" = G."BaseUom"
LEFT JOIN "UGP1" D ON D."UgpEntry" = G."UgpEntry"
LEFT JOIN "OUOM" U ON U."UomEntry" = D."UomEntry"
ORDER BY G."UgpEntry", D."LineNum";

-- 15. Item configuration profiles: kb_15_item_profiles.csv
-- One row per distinct configuration within an item group, not per item.
-- Preserve raw codes; decode against the SDK reference for your B1 version.
SELECT I."ItmsGrpCod", G."ItmsGrpNam", I."InvntItem", I."PrchseItem",
       I."SellItem", I."ManBtchNum", I."ManSerNum", I."EvalSystem",
       I."PlaningSys", I."PrcrmntMtd", I."InvntryUom",
       COUNT(*) AS "ItemCount"
FROM "OITM" I
LEFT JOIN "OITB" G ON G."ItmsGrpCod" = I."ItmsGrpCod"
GROUP BY I."ItmsGrpCod", G."ItmsGrpNam", I."InvntItem", I."PrchseItem",
         I."SellItem", I."ManBtchNum", I."ManSerNum", I."EvalSystem",
         I."PlaningSys", I."PrcrmntMtd", I."InvntryUom"
ORDER BY I."ItmsGrpCod", I."InvntryUom", I."EvalSystem";

-- 16. Warehouse min/max configuration coverage: kb_16_warehouse_minmax.csv
-- Counts inventory-item OITW records, not current stock or replenishment demand.
-- Warehouses with no eligible records are absent. No quantities are summed
-- across items because their inventory units may differ.
SELECT W."WhsCode", H."WhsName", I."ItmsGrpCod", G."ItmsGrpNam",
       COUNT(*) AS "ItemWarehouseRecords",
       SUM(CASE WHEN COALESCE(W."MinStock", 0) > 0 THEN 1 ELSE 0 END)
           AS "RecordsWithPositiveMinimum",
       SUM(CASE WHEN COALESCE(W."MaxStock", 0) > 0 THEN 1 ELSE 0 END)
           AS "RecordsWithPositiveMaximum",
       SUM(CASE WHEN COALESCE(W."MaxStock", 0) < COALESCE(W."MinStock", 0)
                THEN 1 ELSE 0 END) AS "RecordsWithMaxBelowMin"
FROM "OITW" W
INNER JOIN "OITM" I ON I."ItemCode" = W."ItemCode"
LEFT JOIN "OWHS" H ON H."WhsCode" = W."WhsCode"
LEFT JOIN "OITB" G ON G."ItmsGrpCod" = I."ItmsGrpCod"
WHERE I."InvntItem" = 'Y'
GROUP BY W."WhsCode", H."WhsName", I."ItmsGrpCod", G."ItmsGrpNam"
ORDER BY W."WhsCode", I."ItmsGrpCod";

-- 17. Item unit/conversion usage: kb_17_item_unit_profiles.csv
-- Distinct combinations expose purchasing/sales versus inventory UoM differences.
-- These legacy item factors alone do not describe all document conversions.
SELECT "InvntryUom", "BuyUnitMsr", "NumInBuy", "SalUnitMsr", "NumInSale",
       COUNT(*) AS "ItemCount"
FROM "OITM"
GROUP BY "InvntryUom", "BuyUnitMsr", "NumInBuy", "SalUnitMsr", "NumInSale"
ORDER BY "InvntryUom", "BuyUnitMsr", "SalUnitMsr";
