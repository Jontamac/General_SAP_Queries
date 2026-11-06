/*
    SAP Business One / SAP HANA: basic raw-materials replenishment.
    Run in the company database/schema. One row per inventory item with
    an OITW record in a warehouse whose code starts with RM, even at zero stock.

    Projected Available = RM On Hand - RM Committed + Open Purchase Order Qty.
    Replenish to the summed RM maximum only when projected stock < RM minimum.
    Warehouse and purchase-order totals are aggregated separately to avoid duplicates.

    Purchase supply: open lines on open, non-cancelled item purchase orders,
    receiving into RM warehouses. POR1.OpenInvQty is in inventory UoM, so it
    remains comparable with stock even when the purchasing UoM differs.
    Committed quantity uses OITW.IsCommited, including production commitments
    recorded by SAP against RM warehouses; do not subtract WOR1 demand again.
    No due-date horizon, production supply, transfer supply, lead times, lot sizes,
    BOM explosion or capacity calculation. OITW.OnOrder is deliberately not added.
    Min/max must be populated at warehouse level. Only item groups whose names
    start with 'Raw Materials' are included. Results are sorted by item code.
*/

WITH "RMStock" AS
(
    SELECT
        W."ItemCode",
        SUM(COALESCE(W."OnHand", 0))     AS "OnHand",
        SUM(COALESCE(W."IsCommited", 0)) AS "Committed",
        SUM(COALESCE(W."MinStock", 0))   AS "MinStock",
        SUM(COALESCE(W."MaxStock", 0))   AS "MaxStock"
    FROM "OITW" W
    WHERE W."WhsCode" LIKE 'RM%'
    GROUP BY W."ItemCode"
),
"OpenPurchaseOrders" AS
(
    SELECT
        L."ItemCode",
        SUM(L."OpenInvQty") AS "OpenPurchaseQty"
    FROM "OPOR" H
    INNER JOIN "POR1" L ON L."DocEntry" = H."DocEntry"
    WHERE H."CANCELED" = 'N'
      AND H."DocStatus" = 'O'
      AND H."DocType" = 'I'
      AND L."LineStatus" = 'O'
      AND L."WhsCode" LIKE 'RM%'
      AND L."OpenInvQty" > 0
    GROUP BY L."ItemCode"
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
        COALESCE(P."OpenPurchaseQty", 0) AS "OpenPurchaseQty",
        S."OnHand" - S."Committed"
            + COALESCE(P."OpenPurchaseQty", 0) AS "ProjectedAvailable"
    FROM "RMStock" S
    INNER JOIN "OITM" I ON I."ItemCode" = S."ItemCode"
    INNER JOIN "OITB" G ON G."ItmsGrpCod" = I."ItmsGrpCod"
    LEFT JOIN "OpenPurchaseOrders" P ON P."ItemCode" = S."ItemCode"
    WHERE I."InvntItem" = 'Y'
      AND G."ItmsGrpNam" LIKE 'Raw Materials%'
)
SELECT
    X."ItemCode"           AS "Item Code",
    X."ItemName"           AS "Item Description",
    X."InvntryUom"         AS "Inventory UoM",
    X."OnHand"             AS "RM Stock",
    X."Committed"          AS "RM Committed",
    X."OpenPurchaseQty"  AS "Open Purchase Order Qty",
    X."ProjectedAvailable" AS "Projected Available",
    X."MinStock"           AS "RM Minimum",
    X."MaxStock"           AS "RM Maximum",
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


