#SingleInstance Force
#Include "../useSvaner.ahk"

SvanerApp := Svaner({
    gui: {
        title: "Struct types"
    },
    font: {
        name: "Tahoma"
    },
    events: {
        close: (*) => ExitApp()
    }
})
StructTypes(SvanerApp)
SvanerApp.Show()


/**
 * @param {Svaner} App 
 */
StructTypes(App) {
    Staff := Struct({
        name: String,
        pos:  ["attendeng", "supervisor", "manager"],
        age:  Integer
    })

    staffList := signal([
        { name: "harald", pos: "attendeng", age: 22 },
        { name: "amy", pos: "supervisor", age: 25 },
        { name: "leon", pos: "manager", age: 36 }
    ], { name: "staffList" }).as([Staff])

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
            formCtrls.forEach(ctrl => ctrl.Value := "")
        }
    }

    return (
        App.AddListView(
            { lvOptions: "vstaff-list w250 r6 @lv:label-tip" },
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
                App.AddButton("xs155 yp+30 w80 h25", "Add").onClick(handleAddNewStaff)
            ]
        )
    )
}

; DevToolsUI()