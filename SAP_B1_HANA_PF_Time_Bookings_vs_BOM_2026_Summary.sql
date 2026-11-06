/*
    CONTAMAC_LIVE / SAP HANA: 2026 PF time bookings vs BOM resource default times.
    Read-only. SUMMARY: one row per MOR > operation > resource > time type.
    Companion detail: SAP_B1_HANA_PF_Time_Bookings_vs_BOM_2026_Detail.sql.

    Same scope, joins and assumptions as the detail query:
    - Booking document date (OOTR.U_DocDate) in 2026; all MOR items.
    - Cancelled MORs and booking headers excluded; corrections NOT applied.
    - BOM match on MOR item + revision + routing + operation + resource.
      Duplicate BOM lines are collapsed and flagged, never summed.
    - Default time by type: S = Setup, R = Run, Q = Queue; other codes unmapped.
      BOM totals ASSUMED to be seconds for the BOM quantity.
    - Actual hours = SUM of U_WorkingHours / 3600 (includes number of resources).

    Time type is kept as a grouping level because the BOM default differs for
    setup, run and queue. The BOM default is taken once per group, not per booking.
    Only bookings dated in 2026 are summed: an MOR booked across years shows
    only its 2026 time against the full BOM default.
*/

WITH "BOMResources" AS
(
    SELECT
        B."U_ItemCode"   AS "ItemCode",
        L."U_RevCode"    AS "RevCode",
        L."U_RtgCode"    AS "RtgCode",
        L."U_OprCode"    AS "OprCode",
        L."U_RscCode"    AS "RscCode",
        COUNT(*)         AS "BOMLineCount",
        MAX(B."U_Quantity")  AS "BOMQuantity",
        MAX(L."U_SetupTime") AS "BOMSetupTime",
        MAX(L."U_SetupRate") AS "BOMSetupRate",
        MAX(L."U_RunTime")   AS "BOMRunTime",
        MAX(L."U_RunRate")   AS "BOMRunRate",
        MAX(L."U_QueueTime") AS "BOMQueueTime",
        MAX(L."U_QueueRate") AS "BOMQueueRate",
        MIN(L."U_SetupTotal") AS "MinSetupTotal",
        MAX(L."U_SetupTotal") AS "MaxSetupTotal",
        MIN(L."U_RunTotal")   AS "MinRunTotal",
        MAX(L."U_RunTotal")   AS "MaxRunTotal",
        MIN(L."U_QueueTotal") AS "MinQueueTotal",
        MAX(L."U_QueueTotal") AS "MaxQueueTotal",
        MAX(L."U_NrOfResources") AS "BOMNrOfResources"
    FROM "CONTAMAC_LIVE"."@CT_PF_OBOM" B
    INNER JOIN "CONTAMAC_LIVE"."@CT_PF_BOM16" L
        ON L."Code" = B."Code"
    WHERE COALESCE(B."Canceled", 'N') = 'N'
    GROUP BY
        B."U_ItemCode", L."U_RevCode", L."U_RtgCode", L."U_OprCode", L."U_RscCode"
),
"BookingTotals" AS
(
    SELECT
        M."DocEntry"       AS "MORDocEntry",
        M."DocNum"         AS "MORNumber",
        M."U_Status"       AS "MORStatus",
        M."U_ItemCode"     AS "ItemCode",
        M."U_Description"  AS "ItemDescription",
        I."ItmsGrpCod"     AS "ItemGroupCode",
        G."ItmsGrpNam"     AS "ItemGroupName",
        M."U_Revision"     AS "Revision",
        M."U_RtgCode"      AS "RoutingCode",
        M."U_Quantity"     AS "MORQuantity",
        L."U_OprCode"      AS "OperationCode",
        L."U_RscCode"      AS "ResourceCode",
        L."U_TimeType"     AS "TimeType",
        COUNT(DISTINCT H."DocEntry") AS "BookingDocuments",
        COUNT(*)                     AS "BookingLines",
        MIN(H."U_DocDate")           AS "FirstBookingDate",
        MAX(H."U_DocDate")           AS "LastBookingDate",
        SUM(L."U_WorkingHours")      AS "AppliedTimeStored",
        SUM(L."U_Effort")            AS "EffortStored"
    FROM "CONTAMAC_LIVE"."@CT_PF_OOTR" H
    INNER JOIN "CONTAMAC_LIVE"."@CT_PF_OTR1" L
        ON L."DocEntry" = H."DocEntry"
    INNER JOIN "CONTAMAC_LIVE"."@CT_PF_OMOR" M
        ON M."DocEntry" = L."U_BaseEntry"
    LEFT JOIN "CONTAMAC_LIVE"."OITM" I
        ON I."ItemCode" = M."U_ItemCode"
    LEFT JOIN "CONTAMAC_LIVE"."OITB" G
        ON G."ItmsGrpCod" = I."ItmsGrpCod"
    WHERE H."Canceled" = 'N'
      AND M."Canceled" = 'N'
      AND H."U_DocDate" >= TO_DATE('2026-01-01', 'YYYY-MM-DD')
      AND H."U_DocDate" <  TO_DATE('2027-01-01', 'YYYY-MM-DD')
    GROUP BY
        M."DocEntry", M."DocNum", M."U_Status", M."U_ItemCode", M."U_Description",
        I."ItmsGrpCod", G."ItmsGrpNam", M."U_Revision", M."U_RtgCode",
        M."U_Quantity", L."U_OprCode", L."U_RscCode", L."U_TimeType"
),
"Compared" AS
(
    SELECT
        B.*,
        P."RscCode"      AS "BOMRscCode",
        P."BOMLineCount",
        P."BOMQuantity",
        P."BOMNrOfResources",
        P."MinSetupTotal", P."MaxSetupTotal",
        P."MinRunTotal",   P."MaxRunTotal",
        P."MinQueueTotal", P."MaxQueueTotal",
        CASE B."TimeType"
            WHEN 'S' THEN P."MaxSetupTotal"
            WHEN 'R' THEN P."MaxRunTotal"
            WHEN 'Q' THEN P."MaxQueueTotal"
        END AS "BOMDefaultStored",
        CASE B."TimeType"
            WHEN 'S' THEN P."BOMSetupTime"
            WHEN 'R' THEN P."BOMRunTime"
            WHEN 'Q' THEN P."BOMQueueTime"
        END AS "BOMTimeRaw",
        CASE B."TimeType"
            WHEN 'S' THEN P."BOMSetupRate"
            WHEN 'R' THEN P."BOMRunRate"
            WHEN 'Q' THEN P."BOMQueueRate"
        END AS "BOMRateRaw"
    FROM "BookingTotals" B
    LEFT JOIN "BOMResources" P
        ON P."ItemCode" = B."ItemCode"
       AND P."RevCode"  = B."Revision"
       AND P."RtgCode"  = B."RoutingCode"
       AND P."OprCode"  = B."OperationCode"
       AND P."RscCode"  = B."ResourceCode"
)
SELECT
    C."ItemCode"            AS "Item Code",
    C."ItemDescription"     AS "Item Description",
    C."ItemGroupCode"       AS "Item Group Code",
    C."ItemGroupName"       AS "Item Group",
    C."MORNumber"           AS "MOR Number",
    C."MORStatus"           AS "MOR Status",
    C."Revision"            AS "Revision",
    C."RoutingCode"         AS "Routing",
    C."MORQuantity"         AS "MOR Quantity",
    C."BOMQuantity"         AS "BOM Quantity",
    C."OperationCode"       AS "Operation",
    C."ResourceCode"        AS "Resource",
    R."U_RscName"           AS "Resource Name",
    C."TimeType"            AS "Time Type Code",
    CASE C."TimeType"
        WHEN 'S' THEN 'Setup Time'
        WHEN 'R' THEN 'Run Time'
        WHEN 'Q' THEN 'Queue Time'
        ELSE 'Other (' || COALESCE(C."TimeType", 'blank') || ')'
    END                     AS "Time Type",
    C."BookingDocuments"    AS "Time Booking Documents",
    C."BookingLines"        AS "Time Booking Lines",
    C."FirstBookingDate"    AS "First Booking Date",
    C."LastBookingDate"     AS "Last Booking Date",
    ROUND(C."AppliedTimeStored" / 3600.0, 4) AS "Total Actual Hours",
    ROUND(C."BOMDefaultStored" / 3600.0, 4)  AS "BOM Default Hours",
    ROUND((C."AppliedTimeStored" - C."BOMDefaultStored") / 3600.0, 4)
                            AS "Variance Hours (Actual - BOM)",
    CASE WHEN C."BOMDefaultStored" > 0
         THEN ROUND(100.0 * C."AppliedTimeStored" / C."BOMDefaultStored", 1)
    END                     AS "Actual % of BOM",
    ROUND(C."EffortStored" / 3600.0, 4) AS "Total Actual Effort Hours",
    C."BOMTimeRaw"          AS "BOM Time (Raw)",
    C."BOMRateRaw"          AS "BOM Rate (Raw)",
    C."BOMNrOfResources"    AS "BOM Number of Resources",
    CASE
        WHEN C."BOMRscCode" IS NULL THEN 'Not on BOM routing'
        WHEN C."TimeType" NOT IN ('S', 'R', 'Q') OR C."TimeType" IS NULL
            THEN 'Time type not mapped'
        WHEN C."BOMLineCount" > 1
         AND (C."MinSetupTotal" <> C."MaxSetupTotal"
           OR C."MinRunTotal"   <> C."MaxRunTotal"
           OR C."MinQueueTotal" <> C."MaxQueueTotal")
            THEN 'Multiple BOM lines, different times - review'
        WHEN C."BOMLineCount" > 1 THEN 'Multiple BOM lines'
        ELSE ''
    END                     AS "BOM Match Note",
    C."MORDocEntry"         AS "MOR DocEntry"
FROM "Compared" C
LEFT JOIN "CONTAMAC_LIVE"."@CT_PF_ORSC" R
    ON R."U_RscCode" = C."ResourceCode"
ORDER BY
    C."ItemCode",
    C."MORNumber",
    C."OperationCode",
    C."ResourceCode",
    C."TimeType";
