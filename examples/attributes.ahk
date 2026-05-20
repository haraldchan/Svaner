#SingleInstance Force
#Include "../useSvaner.ahk"

SvanerApp := Svaner({
    gui: {
        title: "Attributes"
    },
    font: {
        name: "Tahoma"
    },
    events: {
        close: (*) => ExitApp()
    }
})
Attributes(SvanerApp)
SvanerApp.Show()

/**
 * @param {Svaner} App
 */
Attributes(App) {
    selectedRadio := signal("first")

    hanleSetSelectedRadio(radio, _) {
        selectedRadio.set(radio.Text)

        if (radio.attributes.radioGroup == "first") {
            MsgBox("Now clicking the first radio!")
        }
    }

    onMount() {
        radios := App["#radio-group"]
        radios.forEach(radio => radio.onClick(hanleSetSelectedRadio))
    }

    return (
        App.AddText("w200 h40", "selected: {1}", selectedRadio),
        
        ; add attributes by using "#<key>=<value>"
        App.AddRadio("w100 h20 #radio-group=first", "first radio"),
        ; value is optional. default value is a empty string.
        App.AddRadio("w100 h20 #radio-group", "second radio"),
        App.AddRadio("w100 h20 #radio-group", "third radio"),
        App.AddRadio("w100 h20 #radio-group", "fourth radio"),
        onMount()
    )
}