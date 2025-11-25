#SingleInstance Force
#Include "../useSvaner.ahk"

SvanerApp := Svaner({
    gui: {
        title: "Just basics"
    },
    font: {
        options: "s10",
        name: "Tahoma"
    },
    events: {
        close: (*) => ExitApp()
    }
})
AsTypeBoundry(SvanerApp)
SvanerApp.Show()


/**
 * @param {Svaner} App 
 */
AsTypeBoundry(App) {
    admin := signal("amy").as(["harald", "amy", "leon"])

    handleSetNewAdmin(*) {
        try {
            admin.set(App["new-admin"].Value)
        } catch Error as e {
            MsgBox(e.Message)
        }
    }

    return (
        App.AddText("vadmin w200 h30", "Current Admin: {1}", admin),
        App.AddEdit("vnew-admin @align[WH]:admin", ""),
        App.AddButton("@align[WH]:admin", "set new admin")
           .onClick(handleSetNewAdmin)
    )
}