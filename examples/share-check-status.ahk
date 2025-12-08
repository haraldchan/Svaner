#SingleInstance Force
#Include "../useSvaner.ahk"

SvanerApp := Svaner({
    gui: {
        title: "Share Check Status"
    },
    font: {
        name: "Tahoma"
    },
    events: {
        close: (*) => ExitApp()
    }
})
SCS(SvanerApp)
SvanerApp.Show()


/**
 * @param {Svaner} App 
 */
SCS(App) {
    Staff := Struct({
        name: String,
        pos:  ["attendent", "supervisor", "manager"],
        age:  Integer
    })

    staffList := signal([
        { name: "harald", pos: "attendent",  age: 22 },
        { name: "amy",    pos: "supervisor", age: 25 },
        { name: "leon",   pos: "manager",    age: 36 },
        { name: "elody",  pos: "attendent",  age: 12 },
        { name: "kevin",  pos: "supervisor", age: 20 },
        { name: "alex",   pos: "supervisor", age: 18 },
    ], { name: "staffList" }).as([Staff])

    ; isSelectAll := signal(false)

    handleAddNewStaff(*) {
        /** @type {Array<Gui.Control>} */
        formCtrls := App[ctrl => ctrl.Name.startsWith("new-")]

        if (formCtrls.find(ctrl => !ctrl.Value)) {
            return
        }

        newStaff := {
            name: App["new-name"].Value,
            pos: App["new-pos"].Value,
            age: Integer(App["new-age"].Value),
        }

        try {
            staffList.set(cur => cur.append(newStaff))
        } catch Error as e {
            msgbox e.Message
            ; formCtrls.forEach(ctrl => ctrl.Value := "")
        }
    }

    showCheckedRows(*) {
        MsgBox(JSON.stringify(App["staff-list"].getCheckedRowNumbers()))
    }

    onMount() {
        shareCheckStatus(
            App["select-all"], 
            App["staff-list"],
            ; isSelectAll
        )
    }

    return (
        App.AddCheckBox("vselect-all w250", "Select all"),
        ; App.AddCheckBox("vselect-all w250", "Select all", { check: isSelectAll }),
        App.AddListView(
            { 
                lvOptions: "vstaff-list w250 r10 @lv:label-tip Checked",
            },
            { 
                keys: ["name", "pos", "age"],
                widths: [80, 80, 80]
            },
            staffList
        ),
        StackBox(App,
            {
                name: "add-new-staff",
                fontOptions: "bold",
                groupbox: {
                    title: "New Staff",
                    options: "Section @align[xw]:staff-list y+3 r6"
                }
            },
            () => [
                App.AddText("xs10 yp+20 w50 h25 0x200", "Name"),
                App.AddEdit("vnew-name x+10 w165", ""),
                App.AddText("xs10 yp+25 w50 h25 0x200", "Position"),
                App.AddEdit("vnew-pos x+10 w165", ""),
                App.AddText("xs10 yp+25 w50 h25 0x200", "Age"),
                App.AddEdit("vnew-age x+10 w165", ""),
                App.AddButton("xs65 yp+30 w80 h25", "Checked Rows").onClick(showCheckedRows),
                App.AddButton("x+10 w80 h25", "Add").onClick(handleAddNewStaff)
            ]
        ),
        onMount()
    )
}