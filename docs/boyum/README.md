# Boyum B1UP Environment Knowledge

Scope: **Contamac Ltd**, company schema **`CONTAMAC_LIVE`**. Source: B1UP System Information copied by the user from SAP on **2026-10-21**. This captures the installed baseline and reported settings; individual customization definitions are still to be collected.

## Installed versions and licensing

| Setting | Reported value |
| --- | --- |
| Add-on | B1 Usability Package **2023.06** |
| Server Component | **2023.6.0.0** |
| SAP version identifier | **1000201 (1000201)**, preserved without feature-pack interpretation |
| Database type | **HANA** |
| Company localization | **GB** |
| Local and system currency | **GBP / GBP** |
| License edition | **Enterprise** |
| Licensed users | **55** |
| License status at capture | **Valid** |
| License period | **30/12/2021 - 01/01/2027** |
| Maximum allowed version | **2026.10.*** |
| License information last updated | **21/10/2026** |

The installed add-on is 2023.06. The license's maximum allowed version is an entitlement limit, not evidence that B1UP 2026.10 is installed. Treat newer vendor features as release-dependent until checked against the installed build.

## Active and inactive modules

Preserve these system-information codes exactly; their complete display-name mapping has not yet been verified for this release. A module being active does not prove that it has configured rules or is used by every user.

| State | Reported module codes |
| --- | --- |
| Active | `FB`, `IPT`, `MF`, `A&EM`, `TOOL`, `MIRO`, `ER`, `B1VAL`, `MDM`, `B1P&D` |
| Inactive | `DD`, `QC`, `TS`, `TC`, `RCMC`, `LM`, `B1S`, `PLD`, `RI`, `B1D`, `BEAS`, `B1MC` |

These are **B1UP module flags**. For example, inactive B1UP code `QC` does not establish that ProcessForce Quality Control is disabled, and inactive `BEAS` does not describe the separate ProcessForce installation.

## Access and application settings

| Setting | Reported value |
| --- | --- |
| Database access type | **Hana (Lazy DI-API)** |
| Database access check | **OK** |
| Database size at capture | **3.3gb** as displayed |
| Adhere to Data ownership | **False** |
| Refresh Interval | **10**, with unit unspecified in the supplied text |
| CR installed runtimes | `v4.0_13.0.4000.0`, `v4.0_14.0.4000.0` |
| CR Do Not Verify DB | **False** |
| Legacy Cockpit Support | **False** |
| File Options Active | **None active** |

The captured session had SAP superuser and B1UP superuser privileges. Its visible menus and successful access checks do not prove the same access for ordinary users. Collect user inclusion/exclusion and authorization settings with each customization.

## Client and regional settings

| Setting | Reported value |
| --- | --- |
| Operating system | Microsoft Windows Server 2019 Datacenter |
| Resolution and DPI | 1920x1080, 100% |
| Font | 12px |
| Culture and UI culture | `en-GB` / `en-GB` |
| Date format | `dd/MM/yyyy` |
| Time format | `HH:mm` |

Retain regional context when interpreting configuration exports, SQL parameters, and macro/date text. Keep explicit SQL date formats and numeric conversions separate from client display formatting.

## Configuration knowledge to collect

For each Universal Function or other customization, record its code, name, type, purpose, active state, source company, user scope, form/item/column context, triggering events, condition, execution order, SQL/macro/code, dependencies, and a known example of expected behavior. Include called UFs, external code files/DLL references, relevant UDFs/UDTs, buttons/placement rules, schedules, and report/printing settings where applicable.

Existing metadata already identifies validation tables `@BOY_40_CONFIG` / `@BOY_40_CONFIGLINES`, Universal Functions in `@BOY_41_FUNCTIONS` and its detail tables, and other Boyum setup objects. Consult [KB05 columns](../kb05_table_columns.txt), [KB06 descriptions](../kb06_user_table_registry.txt), and [KB07 field definitions](../kb07_user_fields.txt) before querying them. Table presence does not reveal the configured business logic; configuration contents have not yet been supplied.

## Vendor reference entry points

Repository implementation: [Sales Order alternative UoM warning](sales-order-alternative-uom.md) contains a proposed Dynamic Code UF, setup instructions, and acceptance checks. Its existence is not evidence of deployment in the company.

Use these references alongside the installed-version baseline:

- [B1UP official help](https://help.boyum-it.com/B1UP/)
- [Universal Functions](https://help.boyum-it.com/B1UP/universalfunctions.html)
- [Validation System](https://help.boyum-it.com/B1UP/b1validationsystem.html)
- [Dynamic Code](https://help.boyum-it.com/B1UP/dynamiccodenetsdk.html)
- [Configuration exports](https://help.boyum-it.com/B1UP/export.html)

Boyum's export documentation states that configuration XML does not automatically include referenced Universal Functions, UDFs, UDTs, or formatted searches. Collect those dependencies separately when building the local reference. Do not assume one exported validation contains everything it calls.
