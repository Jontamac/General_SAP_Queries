/*
    CONTAMAC_LIVE / SAP HANA: 2026 PF time bookings vs BOM resource default times.
    Read-only. DETAIL: one row per original @CT_PF_OTR1 time-booking line.
    Companion summary: SAP_B1_HANA_PF_Time_Bookings_vs_BOM_2026_Summary.sql.

    Scope:
    - Time-booking document date (OOTR.U_DocDate) >= 2026-01-01 and < 2027-01-01.
    - All MOR items/item groups; cancelled MORs and booking headers excluded.
    - Corrections (@CT_PF_OATR/@CT_PF_ATR1) are NOT applied; these are the
      originally booked times, which may since have been corrected/reversed.

    BOM comparison:
    - Matched on MOR item + MOR revision + MOR routing + operation + resource
      against BOM resource lines (@CT_PF_BOM16). Non-cancelled BOMs only.
    - The same operation/resource can appear more than once on a BOM routing.
      Matches are collapsed to one row (MIN/MAX shown) and flagged for review,
      so BOM duplicates cannot multiply booking rows.
    - Default time is chosen by booking time type: S = Setup, R = Run, Q = Queue.
      Other time-type codes are shown raw with no default; confirm their meaning.
    - Default hours use the BOM line's U_SetupTotal/U_RunTotal/U_QueueTotal,
      ASSUMED to be stored seconds for the BOM quantity. Raw BOM time/rate are
      shown for reconciliation. Run time is usually quantity-driven: compare
      MOR quantity to BOM quantity before reading run-time differences.

    Actual time:
    - U_WorkingHours (stored seconds, already includes number of resources),
      presented as hours /3600. Effort (per resource) is shown alongside.
      Compare one known booking with the PF screen before relying on hours.

    Joins: OTR1.DocEntry = OOTR.DocEntry; OTR1.U_BaseEntry = OMOR.DocEntry;
    BOM16.Code = OBOM.Code. ORSC.U_RscCode is uniquely indexed.
    Verified against KB05/PF02 field definitions. Not yet executed against HANA.
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
"BookingRows" AS
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
        H."DocEntry"       AS "BookingDocEntry",
        H."DocNum"         AS "BookingNumber",
        H."U_DocDate"      AS "BookingDate",
        L."LineId"         AS "BookingLineID",
        L."U_OprCode"      AS "OperationCode",
        L."U_RscCode"      AS "ResourceCode",
        L."U_TimeType"     AS "TimeType",
        L."U_NrOfResources" AS "NumberOfResources",
        L."U_WorkingHours" AS "AppliedTimeStored",
        L."U_Effort"       AS "EffortStored"
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
)
SELECT
    B."ItemCode"            AS "Item Code",
    B."ItemDescription"     AS "Item Description",
    B."ItemGroupCode"       AS "Item Group Code",
    B."ItemGroupName"       AS "Item Group",
    B."MORNumber"           AS "MOR Number",
    B."MORStatus"           AS "MOR Status",
    B."Revision"            AS "Revision",
    B."RoutingCode"         AS "Routing",
    B."MORQuantity"         AS "MOR Quantity",
    P."BOMQuantity"         AS "BOM Quantity",
    B."BookingNumber"       AS "Time Booking No",
    B."BookingLineID"       AS "Time Booking Line",
    B."BookingDate"         AS "Time Booking Date",
    B."OperationCode"       AS "Operation",
    B."ResourceCode"        AS "Resource",
    R."U_RscName"           AS "Resource Name",
    B."TimeType"            AS "Time Type Code",
    CASE B."TimeType"
        WHEN 'S' THEN 'Setup Time'
        WHEN 'R' THEN 'Run Time'
        WHEN 'Q' THEN 'Queue Time'
        ELSE 'Other (' || COALESCE(B."TimeType", 'blank') || ')'
    END                     AS "Time Type",
    B."NumberOfResources"   AS "Number of Resources",
    ROUND(B."AppliedTimeStored" / 3600.0, 4) AS "Actual Hours",
    ROUND(CASE B."TimeType"
        WHEN 'S' THEN P."MaxSetupTotal"
        WHEN 'R' THEN P."MaxRunTotal"
        WHEN 'Q' THEN P."MaxQueueTotal"
    END / 3600.0, 4)        AS "BOM Default Hours",
    ROUND(B."EffortStored" / 3600.0, 4) AS "Actual Effort Hours",
    CASE B."TimeType"
        WHEN 'S' THEN P."BOMSetupTime"
        WHEN 'R' THEN P."BOMRunTime"
        WHEN 'Q' THEN P."BOMQueueTime"
    END                     AS "BOM Time (Raw)",
    CASE B."TimeType"
        WHEN 'S' THEN P."BOMSetupRate"
        WHEN 'R' THEN P."BOMRunRate"
        WHEN 'Q' THEN P."BOMQueueRate"
    END                     AS "BOM Rate (Raw)",
    P."BOMNrOfResources"    AS "BOM Number of Resources",
    CASE
        WHEN P."RscCode" IS NULL THEN 'Not on BOM routing'
        WHEN B."TimeType" NOT IN ('S', 'R', 'Q') OR B."TimeType" IS NULL
            THEN 'Time type not mapped'
        WHEN P."BOMLineCount" > 1
         AND (P."MinSetupTotal" <> P."MaxSetupTotal"
           OR P."MinRunTotal"   <> P."MaxRunTotal"
           OR P."MinQueueTotal" <> P."MaxQueueTotal")
            THEN 'Multiple BOM lines, different times - review'
        WHEN P."BOMLineCount" > 1 THEN 'Multiple BOM lines'
        ELSE ''
    END                     AS "BOM Match Note",
    B."AppliedTimeStored"   AS "Actual Time (Stored Seconds)",
    B."BookingDocEntry"     AS "Time Booking DocEntry",
    B."MORDocEntry"         AS "MOR DocEntry"
FROM "BookingRows" B
LEFT JOIN "BOMResources" P
    ON P."ItemCode" = B."ItemCode"
   AND P."RevCode"  = B."Revision"
   AND P."RtgCode"  = B."RoutingCode"
   AND P."OprCode"  = B."OperationCode"
   AND P."RscCode"  = B."ResourceCode"
LEFT JOIN "CONTAMAC_LIVE"."@CT_PF_ORSC" R
    ON R."U_RscCode" = B."ResourceCode"
ORDER BY
    B."ItemCode",
    B."MORNumber",
    B."OperationCode",
    B."ResourceCode",
    B."TimeType",
    B."BookingDate",
    B."BookingNumber",
    B."BookingLineID";
