try
{
    // ===== SAFETY CHECK 1: Confirm we have a form to work with =====
    if (form == null)
    {
        application.StatusBar.SetText("No active form found.",
            BoMessageTime.bmt_Short, BoStatusBarMessageType.smt_Warning);
        return;
    }

    // ===== SAFETY CHECK 2: Confirm it's a Manufacturing Order =====
    string formType = "";
    try { formType = form.TypeEx; } catch { }

    bool looksLikeMOR = false;
    try
    {
        Item testItem = form.Items.Item("Operation");
        if (testItem != null) looksLikeMOR = true;
    }
    catch { }

    if (!looksLikeMOR)
    {
        application.StatusBar.SetText(
            "This function only runs on a Manufacturing Order form. (Form type: " + formType + ")",
            BoMessageTime.bmt_Long, BoStatusBarMessageType.smt_Warning);
        return;
    }

    // ===== STEP 1: Activate the outer "Operations" tab =====
    try
    {
        Item tabItem = form.Items.Item("tab_6");
        Folder opsFolder = (Folder)tabItem.Specific;
        opsFolder.Select();
        System.Threading.Thread.Sleep(300);
    }
    catch (Exception exTab)
    {
        application.StatusBar.SetText("Could not activate Operations tab: " + exTab.Message,
            BoMessageTime.bmt_Long, BoStatusBarMessageType.smt_Error);
        return;
    }

    // ===== STEP 2: Get the Operations matrix =====
    Matrix oprMatrix = null;
    try
    {
        oprMatrix = (Matrix)form.Items.Item("Operation").Specific;
    }
    catch (Exception exOpr)
    {
        application.StatusBar.SetText("Could not access Operations grid: " + exOpr.Message,
            BoMessageTime.bmt_Long, BoStatusBarMessageType.smt_Error);
        return;
    }

    if (oprMatrix == null || oprMatrix.RowCount == 0)
    {
        application.StatusBar.SetText("Operations grid is empty — nothing to process.",
            BoMessageTime.bmt_Medium, BoStatusBarMessageType.smt_Warning);
        return;
    }

    // ===== HARDCODED RULES =====
    string[] ruleOperationCodes  = new string[] {
                                                    "WATERCURE",
                                                    // "FAN_OVENS", // Reserved for a future release.
                                                    // "VAC_OVENS"  // Reserved for a future release.
                                                  };
    string[][] rulePrefixes      = new string[][] {
                                                    new string[] { "BATH_PROGRAM" },
                                                    // new string[] { "FAN_OVEN_PROGRAM" }, // Reserved for a future release.
                                                    // new string[] { "VAC_OVEN_60", "VAC_OVEN_25" } // Reserved for a future release.
                                                  };

    int totalChangedAcrossAll = 0;
    System.Text.StringBuilder summary = new System.Text.StringBuilder();

    // ===== MAIN LOOP: For each rule, find its operation, click it, process its resources =====
    for (int r = 0; r < ruleOperationCodes.Length; r++)
    {
        string targetOpCode = ruleOperationCodes[r];
        string[] targetPrefixes = rulePrefixes[r];

        // ----- Find the row of this operation -----
        int opRow = -1;
        for (int i = 1; i <= oprMatrix.RowCount; i++)
        {
            try
            {
                string opCode = ((EditText)oprMatrix.Columns.Item("U_OprCode").Cells.Item(i).Specific).Value;
                if (opCode != null && opCode.Trim().ToUpper() == targetOpCode)
                {
                    opRow = i;
                    break;
                }
            }
            catch { }
        }

        if (opRow == -1)
        {
            continue; // operation not on this MOR
        }

        // ----- Click the operation row to load its Resources -----
        try
        {
            oprMatrix.SelectRow(opRow, true, false);
            System.Threading.Thread.Sleep(150);
            oprMatrix.Columns.Item("noCol").Cells.Item(opRow).Click(BoCellClickType.ct_Regular, 0);
            System.Threading.Thread.Sleep(1000);
        }
        catch
        {
            summary.Append(targetOpCode + " (click failed); ");
            continue;
        }

        // ----- Get the Resources Grid -----
        Grid rscGrid = null;
        DataTable rscDataTable = null;
        try
        {
            rscGrid = (Grid)form.Items.Item("OprRscGrd").Specific;
            rscDataTable = rscGrid.DataTable;
        }
        catch
        {
            summary.Append(targetOpCode + " (resources grid unavailable); ");
            continue;
        }

        if (rscDataTable == null || rscDataTable.Rows.Count == 0)
        {
            continue; // no resources
        }

        // ----- Zero U_RunTime on matching prefixes -----
        int changedThisOp = 0;

        for (int i = 0; i < rscDataTable.Rows.Count; i++)
        {
            try
            {
                object rscCodeObj = rscDataTable.GetValue("U_RscCode", i);
                string rscCode = (rscCodeObj == null) ? "" : rscCodeObj.ToString().Trim().ToUpper();
                if (string.IsNullOrEmpty(rscCode)) continue;
                // This release only updates BATH_ resources; defer all OVEN resources.
                if (!rscCode.StartsWith("BATH_") || rscCode.Contains("OVEN")) continue;

                bool prefixMatched = false;
                for (int p = 0; p < targetPrefixes.Length; p++)
                {
                    if (rscCode.StartsWith(targetPrefixes[p].ToUpper()))
                    {
                        prefixMatched = true;
                        break;
                    }
                }
                if (!prefixMatched) continue;

                object rtObj = null;
                try { rtObj = rscDataTable.GetValue("U_RunTime", i); } catch { }
                string currentRunTime = (rtObj == null) ? "" : rtObj.ToString();

                bool isZero = false;
                double currentNum = 0;
                if (string.IsNullOrEmpty(currentRunTime))
                {
                    isZero = true;
                }
                else if (double.TryParse(currentRunTime, System.Globalization.NumberStyles.Any,
                                         System.Globalization.CultureInfo.InvariantCulture, out currentNum))
                {
                    isZero = (currentNum == 0);
                }

                if (isZero) continue;

                try
                {
                    rscDataTable.SetValue("U_RunTime", i, 0);
                    System.Threading.Thread.Sleep(100);
                    changedThisOp++;
                }
                catch { /* skip */ }
            }
            catch { /* skip unreadable row */ }
        }

        if (changedThisOp > 0)
        {
            totalChangedAcrossAll += changedThisOp;
            summary.Append(targetOpCode + " (" + changedThisOp + "); ");
        }
    }

    // ===== Nothing changed? Just exit — SAP continues the click, Time Booking opens =====
    if (totalChangedAcrossAll == 0)
    {
        application.StatusBar.SetText(
            "No matching resources needed updating.",
            BoMessageTime.bmt_Medium, BoStatusBarMessageType.smt_Success);
        return;
    }

    // ===== Touch Remarks to flip form into Update mode =====
    try
    {
        EditText remarksEdit = (EditText)form.Items.Item("remBox").Specific;
        string originalRemarks = remarksEdit.Value;
        if (originalRemarks == null) originalRemarks = "";

        remarksEdit.Value = originalRemarks + ".";
        System.Threading.Thread.Sleep(150);
        remarksEdit.Value = originalRemarks;
        System.Threading.Thread.Sleep(150);
    }
    catch (Exception exRem)
    {
        application.StatusBar.SetText(
            "Run Time set to 0 on " + totalChangedAcrossAll + " resource(s) [" + summary.ToString() + "], " +
            "but could not nudge form into Update mode: " + exRem.Message +
            " — please click any header field manually, then click Update.",
            BoMessageTime.bmt_Long, BoStatusBarMessageType.smt_Warning);
        return;
    }

    // ===== Recalculate lead times BEFORE update — works on open form data =====
    try
    {
        form.Select();
        System.Threading.Thread.Sleep(300);
        application.ActivateMenuItem("CT_PF_ReclcOperations");
        System.Threading.Thread.Sleep(1000); // let recalculate finish
    }
    catch (Exception exMenu)
    {
        application.StatusBar.SetText(
            "Run times zeroed, but recalculate menu failed: " + exMenu.Message,
            BoMessageTime.bmt_Long, BoStatusBarMessageType.smt_Warning);
        // no return — still save what we zeroed
    }

    // ===== ONE Update — saves zeroed times AND recalculated lead times together =====
    try
    {
        form.Select();
        System.Threading.Thread.Sleep(300);
        form.Items.Item("1").Click();
        System.Threading.Thread.Sleep(1500); // let SAP post the update
    }
    catch (Exception exUpd)
    {
        application.StatusBar.SetText(
            "Changes made but Update click failed: " + exUpd.Message + " — click Update manually.",
            BoMessageTime.bmt_Long, BoStatusBarMessageType.smt_Warning);
        return;
    }

    application.StatusBar.SetText(
        "Run Time zeroed (" + totalChangedAcrossAll + "): " + summary.ToString() +
        " Recalculated and saved. Opening Time Booking...",
        BoMessageTime.bmt_Medium, BoStatusBarMessageType.smt_Success);
}
catch (Exception ex)
{
    application.StatusBar.SetText("Unexpected error — partial changes may have been made: " + ex.Message,
        BoMessageTime.bmt_Long, BoStatusBarMessageType.smt_Error);
}
