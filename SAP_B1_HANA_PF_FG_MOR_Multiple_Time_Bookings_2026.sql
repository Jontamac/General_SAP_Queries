/*
    CONTAMAC_LIVE / SAP HANA: FG MORs with multiple PF time-booking documents.
    Read-only. One result row per original @CT_PF_OTR1 booking line.

    Scope:
    - MOR CreateDate >= 2026-01-01 and < 2027-01-01; all linked booking dates.
    - Current item groups 101, 102, 103, 109 (FG - RGP/IOL/SIHY/SOFT).
    - More than ONE DISTINCT non-cancelled time-booking document per MOR.
      Multiple resource/time-type lines on one document count as one booking.
    - Show only operation/resource/time-type combinations with more than one
      booking line on the same MOR, counting across task references.
      One Setup (S) and one Runtime (R) line do not qualify as a repeated pair.
    - Cancelled MORs and cancelled time-booking headers are excluded.
      Closed/finished MORs, zero-time lines, backflush and non-PDC bookings
      remain included so the original booking audit trail is visible.
    - Sorted by MOR, operation CODE, resource CODE, time type, task, then date.
      This is code order, not the manufacturing routing's sequence order.

    Interpretation:
    - PDC Reference is OOTR.U_BaseCode, labelled PDC Reference in your metadata.
      It is displayed, not used as a mandatory filter on booking origin.
    - Applied time uses stored U_WorkingHours; effort uses stored U_Effort.
      Seconds-to-hours presentation follows the PF duration convention; compare
      one known booking with the PF screen before relying on converted hours.
      U_WorkingHours already includes the number of resources; do not multiply
      it again. Raw stored values are included for reconciliation.
    - Costs are the recorded booking-line amounts, not today's resource rates.
      Total = time + fixed + variable cost, in company local currency (GBP).
    - Corrections (@CT_PF_OATR/@CT_PF_ATR1) are NOT added to these originals.
      Original costs/times may since have been corrected or fully reversed.
      Target references and cleared/closed flags are shown for investigation.
      This is a booking audit, not a net current-cost report.
    - Repeat flags identify candidates for review, not proven double charges.
      A resource may legitimately have setup/run rows or separate sessions.
      Same Task/Type Rows narrows review to the same MOR resource-line reference,
      operation, resource, and time type. Missing references require manual review.

    Verified against KB05/PF02 field definitions and KB10/PF03 keys.
    Joins: OTR1.DocEntry = OOTR.DocEntry (registered header/child);
    OTR1.U_BaseEntry = OMOR.DocEntry (MOR reference in metadata/vendor API).
    ORSC.U_RscCode has a declared unique index; names cannot multiply rows.
    No MOR resource/operation child joins or employee joins are needed.
    Not yet executed against HANA: reconcile a known MOR in PF before use.

    Vendor references:
    https://learn.computec.one/pl/docs/processforce/2.0/developer-guide/processforce-api/processforce-api-tutorial/example-7-create-time-bookings-document/
    https://learn.computec.one/pl/docs/processforce/2.0/administrator-guide/data-model/views-specification/
    https://learn.computec.one/docs/processforce/2.0/user-guide/manufacturing/time-booking/computec-processforce-costing-for-time-entries/
*/

WITH "BookingRows" AS
(
    SELECT
        M."DocEntry"       AS "MORDocEntry",
        M."DocNum"         AS "MORNumber",
        M."CreateDate"     AS "MORCreatedDate",
        M."U_Status"       AS "MORStatus",
        M."U_ItemCode"     AS "ItemCode",
        M."U_Description"  AS "ItemDescription",
        I."ItmsGrpCod"     AS "ItemGroup",
        H."DocEntry"       AS "BookingDocEntry",
        H."DocNum"         AS "BookingNumber",
        H."U_DocDate"      AS "BookingDate",
        H."U_PostingDate"  AS "PostingDate",
        H."CreateDate"     AS "BookingCreatedDate",
        H."U_BaseCode"     AS "PDCReference",
        H."U_Backflushed"  AS "Backflushed",
        L."LineId"         AS "BookingLineID",
        L."U_LineNum"      AS "BookingPFLineNum",
        L."U_BaseLineNum"  AS "MORResourceLine",
        L."U_OprCode"      AS "OperationCode",
        L."U_RscCode"      AS "ResourceCode",
        L."U_TimeType"     AS "TimeType",
        L."U_StartDate"    AS "StartDate",
        L."U_StartTime"    AS "StartTime",
        L."U_EndDate"      AS "EndDate",
        L."U_EndTime"      AS "EndTime",
        L."U_WorkingHours" AS "AppliedTimeStored",
        L."U_Effort"       AS "EffortStored",
        L."U_NrOfResources" AS "NumberOfResources",
        L."U_TimeCost"     AS "TimeCost",
        L."U_FixedCost"    AS "FixedCost",
        L."U_VariableCost" AS "VariableCost",
        L."U_TargetEntry"  AS "TargetDocEntry",
        L."U_TargetLieNum" AS "TargetLineNum",
        L."U_IsCleared"    AS "IsCleared",
        L."U_Closed"       AS "LineClosed"
    FROM "CONTAMAC_LIVE"."@CT_PF_OMOR" M
    INNER JOIN "CONTAMAC_LIVE"."OITM" I
        ON I."ItemCode" = M."U_ItemCode"
    INNER JOIN "CONTAMAC_LIVE"."@CT_PF_OTR1" L
        ON L."U_BaseEntry" = M."DocEntry"
    INNER JOIN "CONTAMAC_LIVE"."@CT_PF_OOTR" H
        ON H."DocEntry" = L."DocEntry"
    WHERE M."Canceled" = 'N'
      AND H."Canceled" = 'N'
      AND I."ItmsGrpCod" IN (101, 102, 103, 109)
      AND M."CreateDate" >= TO_DATE('2026-01-01', 'YYYY-MM-DD')
      AND M."CreateDate" <  TO_DATE('2027-01-01', 'YYYY-MM-DD')
),
"MORBookingCounts" AS
(
    SELECT
        "MORDocEntry",
        COUNT(DISTINCT "BookingDocEntry") AS "MORBookingDocuments"
    FROM "BookingRows"
    GROUP BY "MORDocEntry"
    HAVING COUNT(DISTINCT "BookingDocEntry") > 1
),
"CountedRows" AS
(
    SELECT
        B.*,
        C."MORBookingDocuments",
        COUNT(*) OVER
        (
            PARTITION BY B."MORDocEntry", B."OperationCode", B."ResourceCode",
                         B."TimeType"
        ) AS "OperationResourceTypeRows",
        COUNT(*) OVER
        (
            PARTITION BY B."MORDocEntry", B."MORResourceLine",
                         B."OperationCode", B."ResourceCode", B."TimeType"
        ) AS "SameTaskTypeRows"
    FROM "BookingRows" B
    INNER JOIN "MORBookingCounts" C ON C."MORDocEntry" = B."MORDocEntry"
)
SELECT
    B."MORNumber"           AS "MOR Number",
    B."MORDocEntry"         AS "MOR DocEntry",
    B."MORCreatedDate"      AS "MOR Created Date",
    B."MORStatus"           AS "MOR Status",
    B."ItemCode"            AS "FG Item Code",
    B."ItemDescription"     AS "FG Item Description",
    B."ItemGroup"           AS "Item Group",
    B."MORBookingDocuments" AS "MOR Booking Document Count",
    B."OperationCode"       AS "Operation",
    B."ResourceCode"        AS "Resource",
    R."U_RscName"           AS "Resource Name",
    B."MORResourceLine"     AS "MOR Resource Line",
    B."TimeType"            AS "Time Type Code",
    B."OperationResourceTypeRows" AS "Operation Resource Time Type Booking Rows",
    B."SameTaskTypeRows"    AS "Same Task Type Booking Rows",
    CASE
        WHEN B."MORResourceLine" IS NULL
          OR NULLIF(TRIM(B."OperationCode"), '') IS NULL
          OR NULLIF(TRIM(B."ResourceCode"), '') IS NULL
          OR NULLIF(TRIM(B."TimeType"), '') IS NULL
        THEN 'Missing reference - review'
        WHEN B."SameTaskTypeRows" > 1 THEN 'Repeated task/time type - review'
        WHEN B."OperationResourceTypeRows" > 1 THEN 'Repeated operation/resource/time type - review'
        ELSE ''
    END AS "Review Flag",
    B."BookingNumber"       AS "Time Booking ID",
    B."BookingDocEntry"     AS "Time Booking DocEntry",
    B."BookingLineID"       AS "Booking Line ID",
    B."BookingPFLineNum"    AS "Booking PF Line Number",
    B."BookingDate"         AS "Booking Date",
    B."PostingDate"         AS "Posting Date",
    B."BookingCreatedDate"  AS "Booking Created Date",
    B."PDCReference"        AS "PDC Reference",
    B."Backflushed"         AS "From Backflush",
    B."StartDate"           AS "Start Date",
    B."StartTime"           AS "Start Time (Stored)",
    B."EndDate"             AS "End Date",
    B."EndTime"             AS "End Time (Stored)",
    B."NumberOfResources"   AS "Number of Resources",
    B."AppliedTimeStored"   AS "Applied Time (Stored Seconds)",
    ROUND(B."AppliedTimeStored" / 3600.0, 6) AS "Applied Resource Hours",
    B."EffortStored"        AS "Effort (Stored Seconds)",
    ROUND(B."EffortStored" / 3600.0, 6) AS "Effort Hours",
    B."TimeCost"            AS "Recorded Time Cost (GBP)",
    B."FixedCost"           AS "Recorded Fixed Cost (GBP)",
    B."VariableCost"        AS "Recorded Variable Cost (GBP)",
    COALESCE(B."TimeCost", 0) + COALESCE(B."FixedCost", 0)
        + COALESCE(B."VariableCost", 0) AS "Recorded Total Cost (GBP)",
    B."TargetDocEntry"      AS "Target DocEntry",
    B."TargetLineNum"       AS "Target Line Number",
    B."IsCleared"           AS "Is Cleared",
    B."LineClosed"          AS "Booking Line Closed"
FROM "CountedRows" B
LEFT JOIN "CONTAMAC_LIVE"."@CT_PF_ORSC" R ON R."U_RscCode" = B."ResourceCode"
WHERE B."OperationResourceTypeRows" > 1
ORDER BY
    B."MORNumber",
    B."MORDocEntry",
    B."OperationCode",
    B."ResourceCode",
    B."TimeType",
    B."MORResourceLine",
    B."BookingDate",
    B."BookingDocEntry",
    B."BookingLineID";
