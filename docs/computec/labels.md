# CompuTec Labels

Installed version, user-confirmed **2026-10-15**: **4.7.1.117**. Reviewed on that date. The vendor documentation selector reads **1.00**; it is not the installed build. Check feature-specific minimum versions against 4.7.1.117. Local printers, templates, rules, and services are not yet inventoried.

## Request to output

Labels processes requests for labels and reports using company-specific configuration. It can receive work from SAP B1, ProcessForce, WMS, and PDC. Rules select output and printers; templates and mapped data generate content; the service processes the request. Optional configured outputs include email and PDF attachments. These are available capabilities, not a claim that each is used here. [Labels introduction](https://learn.computec.one/docs/labels/)

```text
Source application and business document
  -> request with company, transaction, and parameters
  -> applicable event/printing/report rules
  -> template and parameter resolution
  -> report/label generation and selected output
  -> request details and logs
```

This is a functional summary; investigate the configured rule path for a particular request.

## Company rules and parameters

The company setup includes printing rules, parameter mappings, event triggers, report rules, and object settings. Printing rules can distinguish requester, transaction, user/employee, item group, warehouse, branch, and other conditions. Parameter mappings can supply built-in values or SQL-derived values. Event triggers distinguish additions, changes, and no automatic action. A stored-procedure option can supply template selection; returned template names must match configured templates. [Company configuration](https://learn.computec.one/docs/labels/setup/configuration/company-installation-and-configuration/)

Investigate three separate questions: what caused the request, which rule/template matched, and what values were supplied. A correct label layout with incorrect mapped values is a different fault from selecting the wrong template or printer.

The documented service/Manager setup includes server configuration and objects/settings for each company. Ensure the selected company is correct before comparing two requests; configuration in one of the eight live/test schemas does not prove equivalent settings in another. [Setup overview](https://learn.computec.one/docs/labels/setup/overview/), [general configuration](https://learn.computec.one/docs/labels/setup/configuration/general-configuration/)

## Requests and processing evidence

The Manager's Requests view can filter by date and other columns. Request Details exposes templates, print parameters, and errors. Start with the request identity, company, source transaction, and submitted parameters, then inspect processing evidence. A request's presence does not by itself prove that the intended physical labels emerged correctly. [Requests](https://learn.computec.one/docs/labels/setup/requests/review-requests/)

The vendor documents structured per-request process logs from **Labels 4.8.9**, with phases for receipt, template selection, parameters, rendering, printing, and completion. These structured logs are outside the confirmed **4.7.1.117** build; use available Requests details and general service logs for this installation. The documented log directory is `C:\ProgramData\CompuTec\CT Label Printing\Logs\`. [Processing logs](https://learn.computec.one/docs/labels/setup/logs/)

## AppEngine request viewer

The CompuTec Docs/CTLabel plugin provides a request viewer with company, requester, status, printer, transaction, and date filters. Request details expose errors and run parameters. Reprint can choose a different printer; the documented action creates another request. Preserve original/reprint identities when investigating duplicate labels rather than counting requests as unique business documents. [Labels plugin](https://learn.computec.one/docs/labels/ct-labels-plugin/ct-label/)

This viewer complements the printing service; its availability alone does not establish that local printer connectivity, template rules, or output destinations are configured correctly.

## Repository investigation guidance

1. Capture request ID, company/schema, requester, transaction/document, template, printer, copies, parameters, and processing status.
2. Check whether the source created an additional request on both add and update, or whether an operator requested a reprint.
3. Inspect rule selection and parameter-query result grain before changing SQL. An unintended extra row can affect output multiplicity.
4. Distinguish a repeated print request from a repeated goods movement or time booking; correlate actual document identities.
5. Verify available objects/columns in KB04/KB05 and registered labels in KB06/KB07. Do not assume request/service history resides entirely in the company schema.

Capture local rules and templates as reviewed configuration facts, excluding credentials and sensitive document data. Use direct source links for detailed installation and reprint procedures rather than copying vendor examples wholesale.
