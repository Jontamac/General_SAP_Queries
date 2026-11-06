# CompuTec ProcessForce

Installed version, user-confirmed **2026-10-15**: **CompuTec ProcessForce 10.0 (10.0.20.15), Release 20 HF 2, 64-bit**. This build is explicitly listed in the [ProcessForce 2.0 release branch](https://learn.computec.one/docs/processforce/2.0/releases/download/); use the [2.0 documentation](https://learn.computec.one/docs/processforce/2.0/) as the primary installation reference.

Reviewed **2026-10-15**. Several general workflow sources below are from the newer 3.0 branch; they describe vendor concepts, not confirmation of R20 feature availability or deployment. Time-booking/API references use 2.0 sources. Check release-specific behavior before applying newer instructions.

## Manufacturing model

ProcessForce adds manufacturing-specific data and business logic to SAP Business One through UDTs, UDFs, UDOs, and APIs. It supports HANA and SQL Server; HANA deployments may also use calculation views and the CompuTec Semantic Model. User queries and Crystal Reports are additional reporting routes. These layers are not interchangeable schema definitions. [Architecture](https://learn.computec.one/docs/processforce/administrator-guide/computec-processforce-architecture/)

The BOM defines required components and can include coproducts, scrap, WIP items, and multiple revisions. The routing describes operations and their resource sequence. Keep the item, revision, routing, operation, and resource-line context when comparing planned and actual production. [BOM](https://learn.computec.one/docs/processforce/user-guide/formulations-and-bill-of-materials/bill-of-materials/overview/), [routings](https://learn.computec.one/docs/processforce/user-guide/routings/overview/)

## Manufacturing orders

MOR creation can start from a BOM, manual entry, a sales order, or saved MRP recommendations. Relevant items, resources, BOM, and permissions must exist first. A sales-order-created MOR can inherit item, revision, quantity, and required-date information. When reporting by year, explicitly choose creation, required, planned, booking, or posting date rather than treating them as equivalent. [MOR creation](https://learn.computec.one/docs/processforce/user-guide/manufacturing/manufacturing-order/overview/)

The documented statuses distinguish planning from execution: Not Scheduled, Scheduled, Released, Started, Finished, and Closed. Released permits production issues/receipts; Started reflects execution; Finished blocks further processing subject to permitted status changes; Closed locks editing and can trigger variance postings if configured. Starting an operation in PDC can move a Released MOR to Started. Check permitted transitions in the installed version. [MOR statuses](https://learn.computec.one/docs/processforce/user-guide/manufacturing/manufacturing-order/manufacturing-order-statuses/)

## Time bookings and corrections

Time Bookings record resource work against a MOR. A document can contain multiple resource and time-type lines. Users can create it directly or from the MOR; the header action can copy all associated resource times, while a resource-line action copies that resource. Calendar settings and resource count affect duration/cost interpretation. Cost values can be edited separately from time. [Time Bookings, 2.0](https://learn.computec.one/docs/processforce/2.0/user-guide/manufacturing/time-booking/time-bookings/)

Time Corrections adjust an earlier booking. The vendor distinguishes corrected duration/total cost on the correction document from the difference posted in its journal entry. A full reversal can use zero corrected duration and costs. Do not add full booking and correction totals to calculate a net cost without following the correction chain. Use the MOR context menu's Time Recording Report for reconciliation. [Costing for time entries, 2.0](https://learn.computec.one/docs/processforce/2.0/user-guide/manufacturing/time-booking/computec-processforce-costing-for-time-entries/)

The 2.0 API example links a booking line to a MOR by `U_BaseEntry` and to its MOR resource line by `U_BaseLineNum`; it separately supplies operation, resource, and time type. It also describes working time as effort multiplied by resource count. This is evidence for the booking reference pattern, not a foreign-key declaration. [API example](https://learn.computec.one/pl/docs/processforce/2.0/developer-guide/processforce-api/processforce-api-tutorial/example-7-create-time-bookings-document/)

## Costing and quality

Item costing rolls material, resource, and overhead costs upward through product structures. Warehouse, revision, and cost category can distinguish costing records. A cost roll-up and an actual historical time-booking cost answer different questions; preserve their dates and categories. [Item costing](https://learn.computec.one/docs/processforce/user-guide/costing-material-and-resources/item-costing/overview/)

Quality Control covers inbound receipts, in-process MOR/operation testing, and inventory inspection or retesting. Definitions specify properties, frequency, applicable transactions, and resources/items used for tests. A warehouse called quarantine or inspection does not alone establish a batch's test result or release status. [Quality Control](https://learn.computec.one/docs/processforce/user-guide/quality-control/overview/)

## Planning traceability and maintenance

Scheduling uses resources, calendars, and tooling to place MOR work on a Gantt view and expose constraints or conflicts. Calendar working patterns and availability affect capacity; a required date alone is not evidence that capacity exists. [Scheduling](https://learn.computec.one/docs/processforce/user-guide/scheduling/overview/)

The legacy MRP article, labelled **10.0**, describes using the SAP B1 wizard and saved recommendations to create scheduled ProcessForce MORs with backward scheduling. Recheck the installed planning module and synchronization settings before applying this older workflow. The repository's simple min/max SQL scripts are not equivalent to the full wizard or a capacity schedule. [Legacy MRP workflow](https://learn.computec.one/docs/processforce/user-guide/mrp/overview)

Batch Traceability follows an item/batch through purchases, manufacturing consumption/output, and onward use or delivery. Its backward and forward views support investigation of source materials and affected products. Use actual batch identities and transaction references when reproducing this in SQL; text batch names alone do not establish cross-item relationships. [Batch Traceability](https://learn.computec.one/docs/processforce/user-guide/inventory/batch-control/batch-traceability/)

Plant Maintenance organizes maintainable equipment, maintenance work/resources, meter readings, and inspection measurements. Its presence in the product does not mean maintenance workflows are implemented here. Confirm local asset/resource links and configured work-order processes before reporting maintenance costs or downtime from those records. [Plant Maintenance](https://learn.computec.one/docs/processforce/user-guide/plant-maintenance/overview/)

## Confirmed local schema anchors

These names come from the supplied company metadata, not from generic documentation:

| Business area | Physical tables |
| --- | --- |
| MOR header and planned operation/resource lines | `@CT_PF_OMOR`, `@CT_PF_MOR12`, `@CT_PF_MOR16` |
| Original time booking header/lines | `@CT_PF_OOTR`, `@CT_PF_OTR1` |
| Time correction header/lines | `@CT_PF_OATR`, `@CT_PF_ATR1` |
| Resource master | `@CT_PF_ORSC` |
| Quality Control tests | `@CT_PF_OQCT` |
| Pick order header/required items | `@CT_PF_OPOR`, `@CT_PF_POR1` |

Verify field-level evidence in [PF02](../pf02_table_columns.txt), descriptions in [PF06](../pf06_user_fields.txt), memberships in [PF05](../pf05_udo_tables.txt), and keys in [PF03](../pf03_constraints.txt). [PF07](../pf07_user_table_registry.txt) identifies log tables; do not mix current and history rows merely because columns match.

For repeated-booking analysis, count booking documents separately from lines, retain task/time type and PDC references, and investigate corrections before calling repeated rows duplicate charges. The existing [2026 FG booking audit](../../SAP_B1_HANA_PF_FG_MOR_Multiple_Time_Bookings_2026.sql) uses current FG groups 101/102/103/109 and MOR creation date. Its final filter requires multiple lines for the same MOR, operation, resource, and time type; a single Setup line plus a single Runtime line does not qualify.
