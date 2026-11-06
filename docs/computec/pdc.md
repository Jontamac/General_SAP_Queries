# CompuTec PDC

Installed version, user-confirmed **2026-10-15**: **3.10.18.2**, with AppEngine **2.10.11.5** also user-confirmed. The [AppEngine 2.0 PDC release listing](https://learn.computec.one/pl/docs/appengine/2.0/releases/plugins/pdc/download/) includes this exact PDC build. A PDC 3.x version does not imply AppEngine 3.0.

Reviewed **2026-10-15**. Operational sources are from the PDC documentation branch labelled 3.0; check individual features against build 3.10.18.2. Task policies, device settings, and enabled integrations remain unconfirmed.

Upgrade research reviewed **2026-10-22**: [3.10.18.2 versus PDC 4.x comparison and vendor screenshots](pdc-3-to-4-comparison.md). Latest publicly documented release found on the live vendor page: **4.2610.1**, dated **7 October 2026**. This is a research target, not a change to the confirmed installed baseline. The comparison includes the vendor's **31 December 2026** end-of-updates notice for AppEngine/ProcessForce 2.0 and explains screenshot/version limitations.

## Tasks and production records

PDC captures shop-floor production activity through ProcessForce. A user selects a MOR, one of its operations, and a resource to establish a task. The task panel distinguishes setup, run, and downtime and can record produced, rework, and scrap quantities. Work registration creates ProcessForce Time Bookings; a visible task is not itself the booking document. [PDC introduction](https://learn.computec.one/docs/pdc/)

For reporting, keep these identities separate:

| Identity | Question it answers |
| --- | --- |
| MOR | Which manufacturing order was worked on? |
| Operation and resource-line reference | Which planned task/resource assignment? |
| PDC task/reference | Which shop-floor activity context? |
| PF booking document and line | Which saved time entry and amount? |
| Employee/team record | Who participated? |

The distinctions are an analysis model for this repository. Determine actual record links from exported metadata and a known application example; a shared resource code does not identify all five levels.

## Task panel behavior

The panel shows planned, actual, and booked setup/run time. Operation and resource property definitions originate in ProcessForce; PDC can capture observed values against them. Quantity can be registered without closing a task. Resource count changes cumulative recorded work: multiple machines working concurrently can produce more resource-hours than elapsed hours. The vendor notes a default PDC resource count of one, independently of the resource master default. Confirm the count on the actual entry. [Task activities](https://learn.computec.one/docs/pdc/user-guide/task-activities/overview/)

Production issue and receipt actions have warehouse/bin prerequisites on the resource. Their completion paths differ: the documented issue deducts materials directly, while the described receipt path can need confirmation through ProcessForce, with other quick/automatic options available. Do not assume every production button immediately posts the same type of inventory document. [Task activities](https://learn.computec.one/docs/pdc/user-guide/task-activities/overview/)

## Quick bookings and downtime

Quick Time Booking works across multiple MORs from one panel. Filters include MOR status, operation, resource, order numbers, required dates, and task start dates. Users select rows to save and confirm their time/quantity entries. The guide says queue and stock time are handled in SAP B1 rather than through this PDC function. One user confirmation need not imply one MOR, resource line, or time type. [Quick Time Booking](https://learn.computec.one/docs/pdc/user-guide/task-activities/quick-time-booking/)

Downtime includes a reason and can involve technicians or supervisors. ProcessForce/PDC settings can control new-task creation, task pausing, and the action taken on downtime registration. Separate downtime intervals from productive work and inspect these choices when investigating apparent repeated sessions. [Downtime](https://learn.computec.one/docs/pdc/user-guide/task-activities/downtime/)

Application settings also include obtaining operation date/time from the database server and closing associated labour when closing a task. Time-zone and employee-session interpretations therefore require the deployed settings, not only timestamps. [Application setup](https://learn.computec.one/docs/pdc/administrator-guide/setting-up-the-application/overview/)

## Investigating repeated bookings

Use the following comparison sequence for the existing local booking audit:

1. Compare MOR, operation, resource, and MOR resource-line reference.
2. Separate time types, then compare PDC reference, booking document/line, recorded start/end values, applied work, effort, and number of resources.
3. Check whether separate legitimate sessions, partial quantity confirmations, teams, or quick bookings explain multiple records.
4. Review time corrections and reversals before estimating excess cost. The vendor distinguishes original bookings, corrected totals, and journal-entry differences. [Time-entry costing](https://learn.computec.one/docs/processforce/2.0/user-guide/manufacturing/time-booking/computec-processforce-costing-for-time-entries/)
5. Reconcile the entries with the MOR's Time Recording Report and the operator's task history. Repeated lines are investigation candidates, not proof of a duplicate charge.

Steps 1-3 and 5 are repository investigation guidance. In the supplied schema, `@CT_PF_OOTR.U_BaseCode` is labelled PDC Reference; `@CT_PF_OTR1` contains MOR/resource/time references and recorded costs. Verify any task-history or employee-table join before adding it: one-to-many employee rows can multiply resource costs.

## Version and configuration checks

User confirmation **2026-10-22**: Contamac uses weighing screens in the current environment. Scale models, drivers, and exact settings remain unconfirmed. See [PDC 4.x weighing evidence and screenshots](pdc-4-weighing.md) before planning migration; documented 4.x weight capture does not by itself establish full wizard/board parity.

The installation documentation identifies an AppEngine-plugin deployment for specified PDC release families. Check the exact PDC build and supported ProcessForce/AppEngine combination rather than treating all historical installations alike. [Installation overview](https://learn.computec.one/docs/pdc/administrator-guide/installation/overview/)

Record the deployed versions, task-creation rules, downtime options, resource-count policy, clock source, team/labour behavior, and posting/receipt choices as local facts when confirmed. PDC credentials and licensing are operational configuration, not material to store in this repository.
