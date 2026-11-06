/*
    SAP Business One / SAP HANA: newest 10 items in groups starting with FG.
    Run in the company database/schema.
    First order means earliest non-cancelled sales order by posting date,
    with DocEntry ascending breaking same-date ties. Includes closed orders.
    First order quantity is the item's total ordered quantity on that SO, in inventory
    UoM, summed across repeated lines. It is not the remaining open quantity.
    Total ordered quantity covers all non-cancelled sales orders, open and closed,
    with no date restriction. Quantities reflect current saved order lines.
    Items without an SO remain visible with NULL first order details and zero total.
    Item creation ties are resolved by creation time, then item code.
*/

WITH "NewestItems" AS
(
    SELECT TOP 10
        I."ItemCode",
        I."ItemName",
        G."ItmsGrpNam",
        I."CreateDate",
        I."CreateTS",
        I."InvntryUom"
    FROM "OITM" I
    INNER JOIN "OITB" G ON G."ItmsGrpCod" = I."ItmsGrpCod"
    WHERE G."ItmsGrpNam" LIKE 'FG%'
    ORDER BY I."CreateDate" DESC,
             COALESCE(I."CreateTS", 0) DESC,
             I."ItemCode" DESC
),
"OrderTotals" AS
(
    SELECT
        L."ItemCode",
        H."DocEntry",
        H."DocNum",
        H."DocDate",
        SUM(L."InvQty") AS "OrderQty"
    FROM "ORDR" H
    INNER JOIN "RDR1" L ON L."DocEntry" = H."DocEntry"
    INNER JOIN "NewestItems" I ON I."ItemCode" = L."ItemCode"
    WHERE H."CANCELED" = 'N'
    GROUP BY L."ItemCode", H."DocEntry", H."DocNum", H."DocDate"
),
"RankedOrders" AS
(
    SELECT
        P.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY P."ItemCode"
            ORDER BY P."DocDate" ASC, P."DocEntry" ASC
        ) AS "SalesRank",
        SUM(P."OrderQty") OVER
        (
            PARTITION BY P."ItemCode"
        ) AS "TotalOrderedQty"
    FROM "OrderTotals" P
)
SELECT
    I."ItemCode"   AS "Item Code",
    I."ItemName"   AS "Item Description",
    I."ItmsGrpNam" AS "Item Group",
    I."CreateDate" AS "Item Created Date",
    P."DocDate"    AS "First Sales Order Posting Date",
    P."DocNum"     AS "First Sales Order No",
    P."OrderQty"   AS "First Order Qty (Inventory UoM)",
    COALESCE(P."TotalOrderedQty", 0) AS "Total Ordered Qty (Inventory UoM)",
    I."InvntryUom" AS "Inventory UoM"
FROM "NewestItems" I
LEFT JOIN "RankedOrders" P
    ON P."ItemCode" = I."ItemCode"
   AND P."SalesRank" = 1
ORDER BY I."CreateDate" DESC,
         COALESCE(I."CreateTS", 0) DESC,
         I."ItemCode" DESC;
