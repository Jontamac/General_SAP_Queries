# CompuTec AppEngine

Installed version, user-confirmed **2026-10-15**: **2.10.11.5**. Use [AppEngine 2.0 documentation](https://learn.computec.one/docs/appengine/2.0/) as the primary reference. The confirmed PDC build **3.10.18.2** is also listed under [AppEngine 2.0 plugins](https://learn.computec.one/pl/docs/appengine/2.0/releases/plugins/pdc/download/).

Reviewed **2026-10-15**. The sections below describe the vendor's **3.0** branch and serve as separate architecture/migration reference. Its .NET 8 prerequisites, PowerShell restrictions, and 3.0 plugin deployment instructions are not the baseline for installed AppEngine 2.10.11.5. [3.0 introduction](https://learn.computec.one/docs/appengine/)

## Runtime and plugin roles

AppEngine provides shared infrastructure for SAP B1 extensions, plugin delivery, APIs, administration, licensing, and automation. The 3.0 platform uses .NET 8. Plugins can expose application functions and custom APIs, while administrator screens manage their deployment and access. Do not confuse an AppEngine plugin with a table prefix, client executable, or a product's complete runtime. [AppEngine introduction](https://learn.computec.one/docs/appengine/)

In the 3.0 ProcessForce/WMS architecture, product components and dependencies are managed through AppEngine. That is version-specific: first identify the actual server, plugins, companies, and client components before applying deployment guidance. [ProcessForce architecture](https://learn.computec.one/docs/processforce/administrator-guide/computec-processforce-architecture/), [WMS installation](https://learn.computec.one/docs/wms/administrator-guide/installation/overview/)

## Companies and instances

An instance hosts plugins and jobs. Instance configuration includes identity/profile, connection endpoints, certificates, and storage locations. Its Companies and Plugins tabs show assignments. Multiple instances can distribute work or support development/pre-release environments; their existence does not prove automatic load balancing or identical plugin assignments. [Instances](https://learn.computec.one/docs/appengine/administrators-guide/configuration-and-administration/appengine-instances/)

For this environment, record each live/test company-to-instance mapping separately. The known main schema is `CONTAMAC_LIVE`; other company names and mappings remain unconfirmed. Match errors to the affected instance and company rather than assuming an installation-wide problem.

## Jobs and triggers

Background jobs can be driven by SAP/business events, cron schedules, or manual execution. One plugin can define several jobs. Event filters restrict which publishers/actions/content types qualify, and assignments specify the company and execution context. A job can be enabled but suspended. Review its assignment and execution history, not merely its presence in a plugin list. [Background Processing](https://learn.computec.one/docs/appengine/administrators-guide/configuration-and-administration/background-processing/)

Useful execution evidence includes start/end, success, completion, messages, exceptions, and connection failures. A background automation can explain a later document/status change, but the documented example job is not evidence that the same job or filters are enabled here. Use actual assignment and execution records to establish cause. [Background Processing](https://learn.computec.one/docs/appengine/administrators-guide/configuration-and-administration/background-processing/)

## Database and upgrade boundaries

The 3.0 requirements distinguish AppEngine's `CTAPPDATA` database from activated SAP B1 company databases and their connection accounts. A successful connection check does not verify every required privilege. Match the vendor's exact runtime, DI API, database, and application prerequisites to the deployed release instead of keeping a generic minimum-version claim. [Requirements](https://learn.computec.one/docs/appengine/administrators-guide/requirements/)

The same guide states that AppEngine 3.0 does not support PowerShell imports/customizations. Identify legacy scripts before a 2.0-to-3.0 migration; do not transplant older API/import examples without checking the supported replacement. These references describe dependencies, not authorization to upgrade or modify the environment. [Requirements](https://learn.computec.one/docs/appengine/administrators-guide/requirements/)

## Diagnosing failures

The vendor lists both Windows Event Viewer and application log files, including `C:\ProgramData\CompuTec\AppEngine\logs`. Correlate timestamps and identifiers with the relevant company, instance, plugin, and background job. [Log files](https://learn.computec.one/docs/appengine/log-files/)

Repository investigation sequence:

1. Identify company, AppEngine generation/build, affected plugin/build, instance, and user context.
2. Establish whether the failure is login/company activation, API access, plugin assignment, business validation, or asynchronous job execution.
3. Inspect compatible component versions, relevant connection/authorization configuration, assignment state, event filters/schedule, and execution messages.
4. Correlate the originating business document or request with any job execution and resulting document.
5. Reconcile retries with original outcomes before treating every execution as a distinct completed business action.

This is investigation guidance, not a claim that a particular job is active. Store confirmed assignment/schedule behavior and relevant configuration facts without secrets. Keep vendor runtime guidance separate from SQL business rules in the company schema.
