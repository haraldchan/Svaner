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
    content := signal("original text loren opsum")
    otherContent := signal("")
    sliderRange := signal(0)

    handleValueUpdate(ctrl, _) {
        otherContent.set(StrUpper(content.value))
    }

    return (
        App.AddEdit("w200 h100 Wrap ReadOnly", "{1}", content),
        App.AddEdit("w200 h100 Wrap ReadOnly", "{1}", otherContent),
        App.AddEdit("vinput w200 r5 @bind", "{1}", content).onChange(handleValueUpdate),

        App.AddEdit("@bind w200 h20 Wrap Number", "{1}", sliderRange),
        App.AddSlider("@bind w200", sliderRange)
    )
}