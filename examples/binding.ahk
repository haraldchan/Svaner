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
Binding(SvanerApp)
SvanerApp.Show()

/**
 * @param {Svaner} App 
 */
Binding(App) {
    cb := signal("This is a CheckBox")
    isChecked := signal(false)

    return (
        App.AddText("w300 h20", "isChecked: {1}", computed(isChecked, cur => cur ? "true" : "false")),
        App.AddCheckBox("vcb! w300 h20", "Checkbox Text:{1}", { text: cb, check: isChecked }).bind()
           .onClick((ctrl, _) => MsgBox(Format("checkbox value: {1}", ctrl.value))),
        App.AddEdit("vedit! w200 h20", "{1}", cb).bind(500)
    )
}