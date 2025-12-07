class shareCheckStatus {
    /**
     * Bind values of CheckBox and ListView for check-all status.
     * @param {Gui.CheckBox} CheckBox Target CheckBox.
     * @param {Gui.ListView} ListView Target Control.
     * @param {signal} depend Associated signal depend.
     */
    __New(CheckBox, ListView, depend) {
        ; param type checking
        TypeChecker.checkType(CheckBox, Gui.CheckBox, "First parameter is not a Gui.CheckBox")
        TypeChecker.checkType(ListView, Gui.ListView, "Second parameter is not a Gui.ListView")
        TypeChecker.checkType(depend, signal, "Third parameter is not a Signal")

        this.cb := CheckBox
        this.lv := ListView
        this.depend := depend

        this.cb.OnEvent("Click", ObjBindMethod(this, "_handleCheckAll"))
        this.lv.OnEvent("ItemCheck", ObjBindMethod(this, "_handleItemCheck"))
    }

    _handleCheckAll(*) {
        this.lv.Modify(0, this.cb.Value == true ? "+Check" : "-Check")
    }

    _handleItemCheck(LV, item, isChecked) {
        ; multi-check
        focusedRows := GuiExt.getFocusedRowNumbers(LV)
        for focusedRow in focusedRows {
            LV.Modify(focusedRow, isChecked ? "Check" : "-Check")
        }

        checkedRows := GuiExt.getCheckedRowNumbers(this.lv)
        this.depend.set(checkedRows.Length == LV.GetCount())
    }
}