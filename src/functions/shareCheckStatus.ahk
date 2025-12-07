/**
 * Bind values of CheckBox and ListView for check-all status.
 * @param {Gui.CheckBox} CheckBox Target CheckBox.
 * @param {Gui.ListView} ListView Target Control.
 * @param {signal} depend Associated signal depend.
 */
shareCheckStatus(CheckBox, ListView, depend) {
    TypeChecker.checkType(CheckBox, Gui.CheckBox, "First parameter is not a Gui.CheckBox")
    TypeChecker.checkType(ListView, Gui.ListView, "Second parameter is not a Gui.ListView")
    TypeChecker.checkType(depend, signal, "Third parameter is not a Signal")

    _handleCheckAll(*) {
        ListView.Modify(0, CheckBox.Value == true ? "+Check" : "-Check")
    }

    _handleItemCheck(LV, item, isChecked) {
        ; multi-check
        focusedRows := GuiExt.getFocusedRowNumbers(LV)
        for focusedRow in focusedRows {
            LV.Modify(focusedRow, isChecked ? "Check" : "-Check")
        }

        checkedRows := GuiExt.getCheckedRowNumbers(LV)
        depend.set(checkedRows.Length == LV.GetCount())
    }

    CheckBox.OnEvent("Click", _handleCheckAll)
    ListView.OnEvent("ItemCheck", _handleItemCheck)
}