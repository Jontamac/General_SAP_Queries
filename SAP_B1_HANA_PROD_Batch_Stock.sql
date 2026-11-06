/*
    SAP Business One for SAP HANA
    Batches currently in stock in warehouse PROD

    Notes
    -----
    - Original purchase information is taken from the first GRPO or direct
      A/P invoice inventory receipt assigned to the batch.
    - OriginalCostPriceLC is the inventory cost in local currency stored in
      the purchasing document row (StockPrice).
    - OriginalPurchasedQty is the inventory-UoM quantity assigned to the
      batch, rather than the purchasing document's full row quantity.
    - For serial/batch-valued items, CurrentValueLC uses the batch value
      balance, apportioned by the quantity held in PROD. Batch cost is
      maintained company-wide by SAP Business One.
    - For all other valuation methods, SAP does not maintain value by batch.
      CurrentValueLC is therefore CurrentQty * the PROD warehouse item cost.
*/

WITH "PurchaseReceiptLines" AS
(
    SELECT
        20                      AS "DocType",
        H."DocEntry"            AS "DocEntry",
        L."LineNum"             AS "LineNum",
        H."DocNum"              AS "DocNum",
        H."DocDate"             AS "DocDate",
        H."CardCode"            AS "SupplierCode",
        H."CardName"            AS "SupplierName",
        H."DocCur"              AS "DocumentCurrency",
        L."StockPrice"          AS "UnitCostLC"
    FROM "OPDN" H
    INNER JOIN "PDN1" L
        ON L."DocEntry" = H."DocEntry"
    WHERE COALESCE(H."CANCELED", 'N') <> 'Y'

    UNION ALL

    SELECT
        18                      AS "DocType",
        H."DocEntry"            AS "DocEntry",
        L."LineNum"             AS "LineNum",
        H."DocNum"              AS "DocNum",
        H."DocDate"             AS "DocDate",
        H."CardCode"            AS "SupplierCode",
        H."CardName"            AS "SupplierName",
        H."DocCur"              AS "DocumentCurrency",
        L."StockPrice"          AS "UnitCostLC"
    FROM "OPCH" H
    INNER JOIN "PCH1" L
        ON L."DocEntry" = H."DocEntry"
    WHERE COALESCE(H."CANCELED", 'N') <> 'Y'
),
"RankedBatchPurchases" AS
(
    SELECT
        D."ItemCode",
        D."SysNumber",
        P."DocType",
        P."DocNum",
        P."DocDate",
        P."SupplierCode",
        P."SupplierName",
        P."DocumentCurrency",
        P."UnitCostLC" AS "OriginalCostPriceLC",
        D."Quantity"   AS "OriginalPurchasedQty",
        ROW_NUMBER() OVER
        (
            PARTITION BY D."ItemCode", D."SysNumber"
            ORDER BY
                T."DocDate",
                T."CreateDate",
                T."CreateTime",
                T."LogEntry"
        ) AS "ReceiptRank"
    FROM "OITL" T
    INNER JOIN "ITL1" D
        ON D."LogEntry" = T."LogEntry"
       AND D."ItemCode" = T."ItemCode"
    INNER JOIN "PurchaseReceiptLines" P
        ON P."DocType"  = T."DocType"
       AND P."DocEntry" = T."DocEntry"
       AND P."LineNum"  = T."DocLine"
    WHERE T."ManagedBy" = 10000044      -- Batch numbers
      AND T."StockEff"  = 1             -- Affects on-hand stock
      AND D."Quantity"  > 0             -- Inventory receipt
),
"OriginalBatchPurchase" AS
(
    SELECT
        "ItemCode",
        "SysNumber",
        "DocType",
        "DocNum",
        "DocDate",
        "SupplierCode",
        "SupplierName",
        "DocumentCurrency",
        "OriginalCostPriceLC",
        "OriginalPurchasedQty"
    FROM "RankedBatchPurchases"
    WHERE "ReceiptRank" = 1
),
"BatchCurrentTotal" AS
(
    SELECT
        "ItemCode",
        "SysNumber",
        SUM("Quantity") AS "AllWarehouseQty"
    FROM "OBTQ"
    GROUP BY
        "ItemCode",
        "SysNumber"
)
SELECT
    Q."WhsCode" AS "Warehouse",
    B."ItemCode" AS "ItemCode",
    I."ItemName" AS "ItemDescription",
    B."MnfSerial" AS "OriginalSupplierBatchNumber",
    B."DistNumber" AS "CurrentSAPBatchNumber",
    CASE B."Status"
        WHEN '0' THEN 'Released'
        WHEN '1' THEN 'Not Accessible'
        WHEN '2' THEN 'Locked'
        ELSE 'Unknown'
    END AS "BatchStatus",
    P."OriginalCostPriceLC",
    P."OriginalPurchasedQty",
    Q."Quantity" AS "CurrentQty",
    CASE
        WHEN I."EvalSystem" = 'B'
         AND COALESCE(T."AllWarehouseQty", 0) <> 0
            THEN B."Balance" * Q."Quantity" / T."AllWarehouseQty"
        ELSE Q."Quantity" * W."AvgPrice"
    END AS "CurrentValueLC",
    CASE
        WHEN I."EvalSystem" = 'B'
         AND COALESCE(B."Quantity", 0) <> 0
            THEN B."CostTotal" / B."Quantity"
        ELSE W."AvgPrice"
    END AS "CurrentUnitCostLC",
    CASE I."EvalSystem"
        WHEN 'A' THEN 'Moving Average'
        WHEN 'S' THEN 'Standard'
        WHEN 'F' THEN 'FIFO'
        WHEN 'B' THEN 'Serial/Batch'
        ELSE 'Unknown'
    END AS "ValuationMethod",
    P."SupplierCode",
    P."SupplierName",
    CASE P."DocType"
        WHEN 20 THEN 'Goods Receipt PO'
        WHEN 18 THEN 'A/P Invoice'
        ELSE NULL
    END AS "OriginalReceiptType",
    P."DocNum" AS "OriginalReceiptNumber",
    P."DocDate" AS "OriginalReceiptDate"
FROM "OBTQ" Q
INNER JOIN "OBTN" B
    ON B."ItemCode"  = Q."ItemCode"
   AND B."SysNumber" = Q."SysNumber"
INNER JOIN "OITM" I
    ON I."ItemCode" = B."ItemCode"
INNER JOIN "OITW" W
    ON W."ItemCode" = Q."ItemCode"
   AND W."WhsCode"  = Q."WhsCode"
INNER JOIN "BatchCurrentTotal" T
    ON T."ItemCode"  = Q."ItemCode"
   AND T."SysNumber" = Q."SysNumber"
LEFT JOIN "OriginalBatchPurchase" P
    ON P."ItemCode"  = Q."ItemCode"
   AND P."SysNumber" = Q."SysNumber"
WHERE Q."WhsCode" = 'PROD'
  AND Q."Quantity" > 0
ORDER BY
    B."ItemCode",
    B."DistNumber";
