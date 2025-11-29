#SingleInstance Force
#Include "../useSvaner.ahk"

SvanerApp := Svaner({
    gui: {
        title: "Just basics"
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
    Contact := Struct({
        tel: Integer,
        email: String
    })

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
        if (!App["new-name"].Value || !App["new-pos"].Value || !App["new-age"].Value) {
            return
        }

        newStaff := {
            name: App["new-name"].Value,
            pos: App["new-pos"].Value,
            age: Integer(App["new-age"].Value),
        }

        staffList.set(cur => cur.append(newStaff))
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