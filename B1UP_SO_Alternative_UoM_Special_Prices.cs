// B1UP 2023.06 Dynamic Code UF: paste this method body into a C# UF.
// Run on Sales Order (139), Add mode, before Add. Uses host form/application/company.
// Warning only: one result per order line / alternative UoM / SPP2 quantity tier.
// Scope: current company, customer, item, active UoM group entries, and posting date.
// SPP2 tiers must belong to the exact SPP1 period covering the order posting date;
// historical/future periods are excluded by FromDate/ToDate, not by row number/year.
// NULL date boundaries are open-ended. There is no fallback to another period.
// Prices are stored SPP2.Price values, not a recalculated SAP pricing result.
// Minimum quantities and discounts are omitted from the message; no conversion is made.
// SAP standard header/matrix item IDs: customer 4, posting date 10, lines 38.
// Line columns are discovered by RDR1 bindings; verify these in the test client.

SAPbobsCOM.Recordset specialPrices = null;
try
{
    if (form == null || form.TypeEx != "139"
        || form.Mode != SAPbouiCOM.BoFormMode.fm_ADD_MODE)
    {
        return;
    }

    string customer = ((SAPbouiCOM.EditText)form.Items.Item("4").Specific).Value.Trim();
    if (customer.Length == 0)
    {
        return;
    }

    string dateText = ((SAPbouiCOM.EditText)form.Items.Item("10").Specific).Value.Trim();
    System.DateTime postingDate;
    if (!System.DateTime.TryParseExact(dateText,
        new string[] { "yyyyMMdd", "dd/MM/yyyy", "yyyy-MM-dd" },
        System.Globalization.CultureInfo.InvariantCulture,
        System.Globalization.DateTimeStyles.None, out postingDate))
    {
        throw new System.Exception("Cannot read the sales order posting date: " + dateText);
    }

    SAPbouiCOM.Matrix lines = (SAPbouiCOM.Matrix)form.Items.Item("38").Specific;
    string itemColumn = null;
    string descriptionColumn = null;
    string uomEntryColumn = null;
    string uomCodeColumn = null;
    for (int c = 0; c < lines.Columns.Count; c++)
    {
        SAPbouiCOM.Column column = lines.Columns.Item(c);
        // Some system columns have no data binding.
        string table = "";
        string alias = "";
        try
        {
            if (column.DataBind.DataBound)
            {
                table = column.DataBind.TableName;
                alias = column.DataBind.Alias;
            }
        }
        catch (System.Runtime.InteropServices.COMException)
        {
            continue;
        }
        if (table != "RDR1") continue;
        if (alias == "ItemCode") itemColumn = column.UniqueID;
        if (alias == "Dscription") descriptionColumn = column.UniqueID;
        if (alias == "UomEntry") uomEntryColumn = column.UniqueID;
        if (alias == "UomCode") uomCodeColumn = column.UniqueID;
    }
    if (itemColumn == null || (uomEntryColumn == null && uomCodeColumn == null))
    {
        throw new System.Exception(
            "Cannot identify the ItemCode and current UoM columns in matrix 38. "
            + "Check the RDR1 column bindings using SAP System Information.");
    }

    System.Func<string, int, string> cellValue = delegate(string columnId, int row)
    {
        if (columnId == null) return "";
        object control = lines.Columns.Item(columnId).Cells.Item(row).Specific;
        SAPbouiCOM.EditText edit = control as SAPbouiCOM.EditText;
        if (edit != null) return edit.Value.Trim();
        SAPbouiCOM.ComboBox combo = control as SAPbouiCOM.ComboBox;
        if (combo != null) return combo.Value.Trim();
        throw new System.Exception("Unsupported cell control in column " + columnId);
    };

    // Read unsaved UI rows. Do not flush or modify the matrix/data sources.
    // Row fields: displayed row, item code, description, UoM entry, UoM code.
    System.Collections.Generic.List<string[]> orderLines =
        new System.Collections.Generic.List<string[]>();
    System.Collections.Generic.Dictionary<string, bool> itemCodes =
        new System.Collections.Generic.Dictionary<string, bool>(System.StringComparer.Ordinal);
    for (int row = 1; row <= lines.RowCount; row++)
    {
        string item = cellValue(itemColumn, row);
        if (item.Length == 0) continue; // Includes the trailing empty row.
        string entry = cellValue(uomEntryColumn, row);
        string code = cellValue(uomCodeColumn, row);
        int parsedEntry;
        bool hasEntry = System.Int32.TryParse(entry,
            System.Globalization.NumberStyles.Integer,
            System.Globalization.CultureInfo.InvariantCulture, out parsedEntry);
        if (!hasEntry && code.Length == 0)
        {
            throw new System.Exception("Cannot read the selected UoM on line " + row);
        }
        orderLines.Add(new string[] {
            row.ToString(System.Globalization.CultureInfo.InvariantCulture), item,
            cellValue(descriptionColumn, row),
            hasEntry ? parsedEntry.ToString(System.Globalization.CultureInfo.InvariantCulture) : "",
            code
        });
        itemCodes[item] = true;
    }
    if (orderLines.Count == 0) return; // Also covers service orders without item codes.

    System.Text.StringBuilder itemList = new System.Text.StringBuilder();
    foreach (string item in itemCodes.Keys)
    {
        if (itemList.Length > 0) itemList.Append(", ");
        itemList.Append("'").Append(item.Replace("'", "''")).Append("'");
    }
    string sqlDate = "TO_DATE('" + postingDate.ToString("yyyyMMdd",
        System.Globalization.CultureInfo.InvariantCulture) + "', 'YYYYMMDD')";
    // Keep all three SPP1 join keys: customer + item + SPP2.SPP1LNum = SPP1.LINENUM.
    // The D.FromDate/D.ToDate predicates below qualify that specific parent period.
    string sql = @"
SELECT
    S.""ItemCode"", I.""ItemName"", S.""UomEntry"", U.""UomCode"", U.""UomName"",
    S.""Price"", S.""Currency"", C.""CardName""
FROM ""SPP2"" S
INNER JOIN ""OCRD"" C ON C.""CardCode"" = S.""CardCode""
INNER JOIN ""OSPP"" P
    ON P.""CardCode"" = S.""CardCode"" AND P.""ItemCode"" = S.""ItemCode""
INNER JOIN ""SPP1"" D
    ON D.""CardCode"" = S.""CardCode"" AND D.""ItemCode"" = S.""ItemCode""
    AND D.""LINENUM"" = S.""SPP1LNum""
INNER JOIN ""OITM"" I ON I.""ItemCode"" = S.""ItemCode""
INNER JOIN ""UGP1"" G
    ON G.""UgpEntry"" = I.""UgpEntry"" AND G.""UomEntry"" = S.""UomEntry""
INNER JOIN ""OUOM"" U ON U.""UomEntry"" = S.""UomEntry""
WHERE S.""CardCode"" = '" + customer.Replace("'", "''") + @"'
    AND S.""ItemCode"" IN (" + itemList.ToString() + @")
    AND S.""UomEntry"" >= 0
    AND P.""Valid"" = 'Y'
    AND G.""IsActive"" = 'Y'
    AND U.""Locked"" = 'N'
    AND (P.""ValidFrom"" IS NULL OR P.""ValidFrom"" <= " + sqlDate + @")
    AND (P.""ValidTo"" IS NULL OR P.""ValidTo"" >= " + sqlDate + @")
    AND (D.""FromDate"" IS NULL OR D.""FromDate"" <= " + sqlDate + @")
    AND (D.""ToDate"" IS NULL OR D.""ToDate"" >= " + sqlDate + @")
ORDER BY S.""ItemCode"", U.""UomCode"", S.""Amount"", S.""SPP1LNum"", S.""SPP2LNum""";

    specialPrices = (SAPbobsCOM.Recordset)company.GetBusinessObject(
        SAPbobsCOM.BoObjectTypes.BoRecordset);
    specialPrices.DoQuery(sql);
    // Price fields: item, master description, UoM entry/code/name, price, currency,
    // customer name. Preserve every configured tier, including zero prices.
    string customerName = "";
    System.Collections.Generic.Dictionary<string, System.Collections.Generic.List<string[]>> prices =
        new System.Collections.Generic.Dictionary<string, System.Collections.Generic.List<string[]>>(
            System.StringComparer.Ordinal);
    while (!specialPrices.EoF)
    {
        string[] values = new string[8];
        for (int f = 0; f < values.Length; f++)
        {
            object value = specialPrices.Fields.Item(f).Value;
            values[f] = value == null || value == System.DBNull.Value ? ""
                : System.Convert.ToString(value, System.Globalization.CultureInfo.InvariantCulture);
        }
        if (!prices.ContainsKey(values[0]))
        {
            prices[values[0]] = new System.Collections.Generic.List<string[]>();
        }
        customerName = values[7];
        prices[values[0]].Add(values);
        specialPrices.MoveNext();
    }

    System.Func<string, string> numberText = delegate(string value)
    {
        decimal number;
        return System.Decimal.TryParse(value, System.Globalization.NumberStyles.Number,
            System.Globalization.CultureInfo.InvariantCulture, out number)
            ? number.ToString("#,0.######", System.Globalization.CultureInfo.GetCultureInfo("en-GB"))
            : "[not set]";
    };
    System.Collections.Generic.List<string> notices = new System.Collections.Generic.List<string>();
    foreach (string[] line in orderLines)
    {
        if (!prices.ContainsKey(line[1])) continue;
        foreach (string[] price in prices[line[1]])
        {
            bool sameUom = line[3].Length > 0
                ? line[3] == price[2]
                : System.String.Equals(line[4], price[3], System.StringComparison.Ordinal);
            if (sameUom) continue;
            string description = line[2].Length > 0 ? line[2] : price[1];
            string currency = price[6].Length > 0 ? price[6] : "[currency not set]";
            notices.Add("Line " + line[0] + ": " + line[1] + " - " + description
                + "\nAlternative UoM: " + price[4] + " (" + price[3] + ")"
                + " - " + currency + " " + numberText(price[5]) + " per UoM");
        }
    }
    // No popup when there are no alternatives. Split large results into readable pages.
    System.Collections.Generic.List<string> pages = new System.Collections.Generic.List<string>();
    System.Text.StringBuilder page = new System.Text.StringBuilder();
    foreach (string notice in notices)
    {
        if (page.Length > 0 && page.Length + notice.Length > 2400)
        {
            pages.Add(page.ToString());
            page.Length = 0;
        }
        if (page.Length > 0) page.Append("\n\n");
        page.Append(notice);
    }
    if (page.Length > 0) pages.Add(page.ToString());
    for (int p = 0; p < pages.Count; p++)
    {
        application.MessageBox("Alternative UoM Special Prices - " + customerName
            + "\n\n" + pages[p], 1, "OK", "", "");
    }
}
catch (System.Exception ex)
{
    application.MessageBox("Alternative UoM special-price check could not complete.\n"
        + ex.Message, 1, "OK", "", "");
}
finally
{
    // Release only the recordset created here, never B1UP's shared company/session.
    if (specialPrices != null && System.Runtime.InteropServices.Marshal.IsComObject(specialPrices))
    {
        System.Runtime.InteropServices.Marshal.ReleaseComObject(specialPrices);
    }
}
