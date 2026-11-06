/*
    SAP HANA / ProcessForce: resource coverage for BOM items starting with 3.
    Read-only; run in the intended company schema. No quantities or unit conversions.
    Run section 1 and section 2 separately in SAP B1 Query Manager.

    Section 1: one row per BOM revision/routing/expected resource.
    Each routing is expected to contain EVERY resource in the selected groups.
    Presence anywhere within that routing counts, including zero-time and
    non-default alternatives. This does not check the assigned operation or time.
    A BOM without a routing is retained and its expected resources are MISSING.
    All revisions/routings are included, without validity-date/default filters.
    Cancelled BOMs/resources are excluded. Resource activity is displayed but
    not filtered: the requested full configured resource list includes inactive ones.

    Assumption: BATHS, FAN OVENS, VAC OVEN are resource group names/codes.
    Spaces/underscores and case are normalized ONLY for selecting these groups.
    VAC OVENS is accepted too. Actual resource comparisons use exact stored codes.
    Confirm the group selection using section 2, especially if section 1 is empty.
    An empty expected-resource list produces no comparison rows, not proof of coverage.
    Change MissingOnly from N to Y to return only missing resources.

    Metadata checked: KB05/KB07, PF05 UDO membership, PF03 declared unique keys.
    Application joins to verify against a known BOM: child Code = header Code;
    resource lines scoped by parent Code, revision and routing; resource master
    U_RscCode; group master U_RscGrpCode. No declared foreign keys are available.
    Repeated resource assignments are deduplicated before the comparison.
    Not executed against HANA. Validate a complete BOM, one missing resource,
    a wholly absent group, multiple revisions/routes, repeated assignments,
    zero-time alternatives, no routing, and cancelled/inactive records in a test company.

    Vendor context (ProcessForce 2.0 production process):
    https://learn.computec.one/pl/docs/processforce/2.0/user-guide/formulations-and-bill-of-materials/production-process/overview/
*/

-- 1. Full comparison. Copy from WITH through the final ORDER BY as one statement.
WITH "Settings" AS
(
    SELECT 'N' AS "MissingOnly" FROM DUMMY
),
"ExpectedResources" AS
(
    SELECT
        R."U_RscCode" AS "ResourceCode",
        R."U_RscName" AS "ResourceName",
        R."U_RscGrpCode" AS "GroupCode",
        G."U_RscGrpName" AS "GroupName",
        R."U_Activity" AS "ResourceActivity"
    FROM "@CT_PF_ORSC" R
    LEFT JOIN "@CT_PF_ORGR" G
        ON G."U_RscGrpCode" = R."U_RscGrpCode"
    WHERE COALESCE(R."Canceled", 'N') = 'N'
      AND R."U_RscCode" IS NOT NULL
      AND
      (
          UPPER(REPLACE(TRIM(G."U_RscGrpName"), '_', ' '))
              IN ('BATHS', 'FAN OVENS', 'VAC OVEN', 'VAC OVENS')
          OR UPPER(REPLACE(TRIM(R."U_RscGrpCode"), '_', ' '))
              IN ('BATHS', 'FAN OVENS', 'VAC OVEN', 'VAC OVENS')
      )
),
"AssignedResources" AS
(
    SELECT DISTINCT
        "Code", "U_RevCode", "U_RtgCode", "U_RscCode"
    FROM "@CT_PF_BOM16"
)
SELECT
    B."U_ItemCode" AS "Item Code",
    B."U_Description" AS "Item Description",
    B."Code" AS "BOM Key",
    B."U_Revision" AS "Revision",
    T."U_RtgCode" AS "Routing",
    T."U_IsDefault" AS "Default Routing",
    E."GroupCode" AS "Resource Group Code",
    E."GroupName" AS "Resource Group",
    E."ResourceCode" AS "Resource Code",
    E."ResourceName" AS "Resource Name",
    E."ResourceActivity" AS "Resource Activity",
    CASE WHEN A."U_RscCode" IS NULL THEN 'MISSING' ELSE 'OK' END AS "Status"
FROM "@CT_PF_OBOM" B
LEFT JOIN "@CT_PF_BOM11" T
    ON T."Code" = B."Code"
CROSS JOIN "ExpectedResources" E
CROSS JOIN "Settings" S
LEFT JOIN "AssignedResources" A
    ON A."Code" = B."Code"
   AND COALESCE(A."U_RevCode", '') = COALESCE(T."U_RevCode", '')
   AND COALESCE(A."U_RtgCode", '') = COALESCE(T."U_RtgCode", '')
   AND A."U_RscCode" = E."ResourceCode"
   AND T."LineId" IS NOT NULL
WHERE B."U_ItemCode" LIKE '3%'
  AND COALESCE(B."Canceled", 'N') = 'N'
  AND (S."MissingOnly" = 'N' OR A."U_RscCode" IS NULL)
ORDER BY
    CASE WHEN A."U_RscCode" IS NULL THEN 0 ELSE 1 END,
    B."U_ItemCode", B."U_Revision", B."Code", T."U_RtgCode",
    E."GroupCode", E."ResourceCode";

-- 2. Resource directory: run separately to confirm the exact group names/codes.
SELECT
    R."U_RscGrpCode" AS "Resource Group Code",
    G."U_RscGrpName" AS "Resource Group",
    R."U_RscCode" AS "Resource Code",
    R."U_RscName" AS "Resource Name",
    R."U_Activity" AS "Resource Activity",
    R."Canceled" AS "Cancelled"
FROM "@CT_PF_ORSC" R
LEFT JOIN "@CT_PF_ORGR" G
    ON G."U_RscGrpCode" = R."U_RscGrpCode"
ORDER BY R."U_RscGrpCode", R."U_RscCode";
