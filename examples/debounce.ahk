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
Debouncer(SvanerApp)
SvanerApp.Show()

/**
 * @param {Svaner} App 
 */
Debouncer(App) {
    content := signal("")

    handleValueUpdate(ctrl, _) {
        content.set(ctrl.Value)
    }

    return (
        App.AddEdit("w200 h200 Wrap ReadOnly", "{1}", content),
        App.AddEdit("vinput w200 r5", "{1}", content).onChange(handleValueUpdate)
    )
}