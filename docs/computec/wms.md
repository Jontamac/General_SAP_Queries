# CompuTec WMS

Installed version, user-confirmed **2026-10-15**: **2.10.20.10**. Reviewed on that date. Operational sources here are labelled WMS 2.0; the 3.0 installation section is separate reference and does not describe the confirmed installed generation. Custom Configuration choices remain unconfirmed.

## Warehouse transactions

WMS connects warehouse clients and scanners with SAP Business One and, where installed, ProcessForce. Users select a transaction, scan or select items, supply quantities and batch/serial/bin details, and complete its workflow. The resulting business document is the reporting evidence; a client action alone is not proof of final stock movement. The product also supports stock counting, packing, storage units, and optional catch-weight workflows. [WMS introduction](https://learn.computec.one/docs/wms/)

A delivery can start from picked items, a pick list, or a sales order. Use the base-document relationship and final delivery identity when tracing an outbound shipment. [Delivery](https://learn.computec.one/docs/wms/user-guide/transactions/delivery/overview/)

For ProcessForce production, the Pick Order workflow can generate a Production Issue from an existing pick order or a MOR. The forms and options shown depend on configuration. Distinguish picking/allocation from the resulting production issue when counting movements. [Pick Order](https://learn.computec.one/docs/wms/user-guide/transactions/pick-order/overview/)

The Pick Receipt workflow supports receipts from ProcessForce production. With Auto Receipt disabled, allocation can be completed before another user posts the production receipt. With automatic posting, separate picks or batch generations can generate separate receipts. A single MOR therefore need not correspond to a single inventory document. [Pick Receipt](https://learn.computec.one/docs/wms/user-guide/transactions/pick-receipt/overview/)

## Storage units and bins

A Storage Unit groups item quantities, such as a pallet's contents, for handling as one unit. Its identity, contents, and status are separate concepts from the warehouse bin holding stock. The vendor cautions against moving WMS storage-unit contents directly through ordinary SAP B1 movements because unit contents and stock can diverge. Confirm the supported workflow before making such changes. [Storage Units](https://learn.computec.one/docs/wms/user-guide/storage-units/overview/)

Local KB02 records 24 warehouses, 10 bin-enabled. Apply bin-level logic only where configured, and establish separately whether storage units, catch weight, or allocation queues are used. Their availability in vendor documentation is not evidence of local adoption.

## Units of measure

WMS can source units differently by transaction and Custom Configuration. Transfer requests can inherit document units; transfers can use inventory or sales units; custom selection queries can supply a `UoM` column. Identify the transaction, item group assignment, document units, and conversion factors before interpreting a displayed quantity. Do not equate a scanner quantity with inventory quantity without that context. [Managing UoM](https://learn.computec.one/docs/wms/user-guide/managing-uom-in-computec-wms/)

For this company, use KB13's exact UoM entries, KB14's group factors, and KB17's actual item profiles. Labels such as `Each`, `each`, and `EACH` are preserved in the source metadata; similar names do not justify merging configurations.

## Client and deployment context

Client settings define server connection, printer/scale integration, warehouse selection, and scanner handling. The information screen exposes company/database, server/client versions, and terminal identity, which are useful for isolating a device-specific problem. Capture those identifiers and relevant logs before comparing two apparently identical workflows. [Starting the client](https://learn.computec.one/docs/wms/user-guide/starting/)

The 3.0 installation uses AppEngine plugins, company/instance assignments, and activated WMS background jobs. The vendor also specifies a ProcessForce API component when ProcessForce is installed. Verify compatibility across these components and the client/server; these dependencies must not be inferred from the older 2.0 operational pages. [WMS 3.0 installation](https://learn.computec.one/docs/wms/administrator-guide/installation/overview/)

## Investigation guidance

1. Identify the company, terminal/user, transaction tile, base document, item, warehouse/bin, UoM, and batch/serial or SU.
2. Establish whether the user saved a draft, allocated/picked stock, or posted a final document.
3. Compare enabled Custom Configuration and automatic posting choices with the relevant version's workflow.
4. Trace the resulting SAP/ProcessForce document and reconcile quantities at its line/allocation grain.
5. For a print problem, trace the Labels request separately; for a time problem, trace the PDC/PF booking rather than inferring time from material movement.

This sequence is repository investigation guidance. Confirm physical table names and keys against the exported dictionaries before building joins; WMS prefixes alone do not establish a relationship or active usage.
