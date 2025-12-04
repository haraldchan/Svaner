#SingleInstance Force
#Include "../useSvaner.ahk"

SvanerApp := Svaner({
    gui: {
        title: "Debounce"
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
        content.set(ctrl.value)
    }

    return (
        App.AddEdit("w200 h100 Wrap ReadOnly", "{1}", content),
        App.AddEdit("w200 h20 Wrap", "{1}", content).onChange(handleValueUpdate, 300)
    )
}