/*
    SAP Business One / SAP HANA: basic finished-goods replenishment.
    Run in the company database/schema. One row per inventory item with
    an OITW record in a warehouse whose code starts with FG, even at zero stock.

    Projected Available = FG On Hand - FG Committed + Open Production Qty.
    Replenish to the summed FG maximum only when projected stock < FG minimum.
    Warehouse and production totals are aggregated separately to avoid duplicates.

    Production supply: planned/released standard or special orders with an FG
    header receipt warehouse. Remaining = MAX(PlannedQty - CmpltQty, 0) per order.
    This assumes rejected output will be replaced to achieve planned good output.
    No due-date horizon, purchase supply, transfer supply, lead times, lot sizes,
    BOM explosion or capacity calculation. OITW.OnOrder is deliberately not added.
    Min/max must be populated at warehouse level. Only item groups whose names
    start with 'Finished Goods' are included. Results are sorted by item code.
*/

WITH "FGStock" AS
(
    SELECT
        W."ItemCode",
        SUM(COALESCE(W."OnHand", 0))     AS "OnHand",
        SUM(COALESCE(W."IsCommited", 0)) AS "Committed",
        SUM(COALESCE(W."MinStock", 0))   AS "MinStock",
        SUM(COALESCE(W."MaxStock", 0))   AS "MaxStock"
    FROM "OITW" W
    WHERE W."WhsCode" LIKE 'FG%'
    GROUP BY W."ItemCode"
),
"OpenProduction" AS
(
    SELECT
        P."ItemCode",
        SUM(
            CASE
                WHEN COALESCE(P."PlannedQty", 0) > COALESCE(P."CmpltQty", 0)
                THEN COALESCE(P."PlannedQty", 0) - COALESCE(P."CmpltQty", 0)
                ELSE 0
            END
        ) AS "OpenProductionQty"
    FROM "OWOR" P
    WHERE P."Warehouse" LIKE 'FG%'
      AND P."Status" IN ('P', 'R') -- Planned / Released
      AND P."Type" IN ('S', 'P')   -- Standard / Special; excludes disassembly
    GROUP BY P."ItemCode"
),
"Position" AS
(
    SELECT
        S."ItemCode",
        I."ItemName",
        I."InvntryUom",
        S."OnHand",
        S."Committed",
        S."MinStock",
        S."MaxStock",
        COALESCE(P."OpenProductionQty", 0) AS "OpenProductionQty",
        S."OnHand" - S."Committed"
            + COALESCE(P."OpenProductionQty", 0) AS "ProjectedAvailable"
    FROM "FGStock" S
    INNER JOIN "OITM" I ON I."ItemCode" = S."ItemCode"
    INNER JOIN "OITB" G ON G."ItmsGrpCod" = I."ItmsGrpCod"
    LEFT JOIN "OpenProduction" P ON P."ItemCode" = S."ItemCode"
    WHERE I."InvntItem" = 'Y'
      AND G."ItmsGrpNam" LIKE 'Finished Goods%'
)
SELECT
    X."ItemCode"           AS "Item Code",
    X."ItemName"           AS "Item Description",
    X."InvntryUom"         AS "Inventory UoM",
    X."OnHand"             AS "FG Stock",
    X."Committed"          AS "FG Committed",
    X."OpenProductionQty"  AS "Open Production Qty",
    X."ProjectedAvailable" AS "Projected Available",
    X."MinStock"           AS "FG Minimum",
    X."MaxStock"           AS "FG Maximum",
    CASE
        WHEN X."ProjectedAvailable" < X."MinStock" THEN 'Y'
        ELSE 'N'
    END AS "Below Minimum",
    CASE
        WHEN X."MaxStock" < X."MinStock" THEN NULL
        WHEN X."ProjectedAvailable" < X."MinStock"
        THEN X."MaxStock" - X."ProjectedAvailable"
        ELSE 0
    END AS "Recommended Replenishment",
    CASE
        WHEN X."MaxStock" < X."MinStock" THEN 'CHECK MIN/MAX: MAX BELOW MIN'
        WHEN X."ProjectedAvailable" < X."MinStock" THEN 'REPLENISH'
        ELSE 'OK'
    END AS "Recommendation"
FROM "Position" X
-- Uncomment to show only items below minimum:
-- WHERE X."ProjectedAvailable" < X."MinStock"
ORDER BY X."ItemCode";
