# Sales Order Alternative UoM Warning

[Dynamic Code UF source](../../B1UP_SO_Alternative_UoM_Special_Prices.cs). Prepared for the reported B1UP 2023.06 / SAP B1 HANA environment; not deployed or tested in SAP.

## Installation

1. Create a Universal Function of type **Dynamic Code**, language **C#**. Paste the complete source file as the method body; do not add a class or `Main` method. Use B1UP's client-side `form`, `application`, and `company` objects and standard SAP UI/DI API references.
2. Compile using the UF editor's **Test** function. This checks compilation, not execution.
3. Configure your validation for **Sales Order, form type 139**, **Add mode**, before the **Add** button action. The standard button item UID is `1`. Invoke this UF once per Add attempt. Do not also trigger it after Add.
4. Verify standard item UIDs `4` (customer), `10` (posting date), and `38` (lines). The code discovers line columns through their `RDR1` bindings: `ItemCode`, `Dscription`, `UomEntry`, and `UomCode`. Missing required bindings produce an error message.
5. Validate in a test company before enabling for users.

## Behavior and scope

The UF reads unsaved matrix rows, including repeated items, and compares each line's selected UoM with the customer's configured special-price UoMs. The header is exactly `Alternative UoM Special Prices - <customer name>`, using `OCRD.CardName`. Each result shows item code and line description (item-master fallback), followed by `Alternative UoM: <name> (<code>) - <currency> <price> per UoM`. Minimum quantity, discount, posting date, and page numbers are omitted from the message. Matching current UoMs are excluded. No matches produce no popup; large results use multiple messages with the same header.

The query joins `SPP2` to its `SPP1` date period, `OSPP`, `OITM`, the item's `UGP1` group entries, `OUOM`, and `OCRD` for the customer name. It requires valid customer special prices, inclusive header/period dates covering the posting date, active group entries, and unlocked nonmanual UoMs.

Period matching uses **all three keys**: customer, item, and `SPP2.SPP1LNum = SPP1.LINENUM`. Only tiers whose own parent `SPP1.FromDate`/`ToDate` cover the sales order's posting date qualify. Expired reference periods and future periods are excluded; no match does not fall back to an older period. A backdated order uses its posting date, not today's date. NULL boundaries are open-ended, so an old row left open or overlapping another period can still qualify according to its configured dates.

Every matching quantity tier is listed, even if the order quantity is below its threshold. Per the user's confirmed usage, minimum quantity and discount are not displayed. The displayed price is **raw `SPP2.Price`**, not a recalculation of SAP's final price; no additional discount is applied. Prices are not compared for savings. No order fields, prices, quantities, or UoMs are changed. This is a warning; errors are reported but this code does not cancel Add.

## Manual acceptance checks

Check a current-UoM-only price, an alternative with multiple tiers, repeated items using different selected UoMs, expired/future prices, a different customer, blank trailing rows, and an order without alternatives. Confirm names, currencies, thresholds, and prices against SAP's Special Prices screen.

Offline verification: .NET Framework compilation with API stubs and 19 C# fixture assertions passed, including the revised customer-name header, UoM/price layout, omitted fields, and pagination. All 30 SQL column references match KB05. The earlier 13 query-filter checks passed in SQLite with a `TO_DATE` shim; the date filters remain identical after the message update. These checks do not verify the installed SAP interop assemblies, actual matrix bindings, HANA execution, or validation event configuration.

Four additional period checks passed against the same query: coexisting 2024/2025/2026/2027 periods return only 2026 prices for a 2026 posting date; a 2025 posting date returns its own period; start/end dates are inclusive; expiring the current period returns no historical/future fallback.

## References

- [Boyum Dynamic Code context and compilation](https://help.boyum-it.com/B1UP/dynamiccodenetsdk.html)
- [SAP SPP2 fields and keys](https://help.sap.com/doc/089315d8d0f8475a9fc84fb919b501a3/10.0/en-US/SDKHelp/SPP2.html)
- [SAP special-price quantity tiers](https://help.sap.com/doc/089315d8d0f8475a9fc84fb919b501a3/10.0/en-US/SDKHelp/SAPbobsCOM~SpecialPricesQuantityAreas.html)

Vendor references reviewed 2026-10-21. Installed-client compilation and UI behavior remain to be checked.
