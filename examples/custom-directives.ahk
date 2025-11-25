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
CustomDirectives(SvanerApp)
SvanerApp.Show()

/**
 * @param {Svaner} App 
 */
CustomDirectives(App) {
    App.defineDirectives(Map(
        "@use:red-text", "cRed",
        "@func:blue-text", ctrl => ctrl.SetFont("cBlue bold s12"),
        "@func:click-to-green", handleGreenify
    ))

    /**
     * @param {Svaner.Control | Gui.Control} ctrl 
     */
    handleGreenify(ctrl) {
        ctrl.onClick((*) => ctrl.SetFont("cGreen", "Verdana"))
    }

    textStyle := "w200 h30 @text:align-center "

    return (
        App.AddText(textStyle . "@use:red-text", "Using red-text"),
        App.AddText(textStyle . "@func:blue-text", "Using callback blue-text"),
        App.AddText(textStyle . "@func:click-to-green", "Click to green!")
    )
}