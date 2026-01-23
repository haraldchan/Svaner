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
    App.defineDirectives(
        "@use:red-text",    "cRed",
        "@use:blue-text",  ctrl => ctrl.SetFont("cBlue bold s12"),
        "@use:greenify",   handleGreenify,
        "@use:sunk",        "0x1000",
        "@use:combination", "@align[wh]:first-text @text:align-center",
        "@use:nested-comb", "@use:combination @use:sunk @use:greenify"
    )

    /**
     * @param {Svaner.Control | Gui.Control} ctrl 
     */
    handleGreenify(ctrl) {
        ctrl.onClick((*) => ctrl.SetFont("cGreen", "Verdana"))
    }

    return (
        App.AddText("vfirst-text w200 h30 @text:align-center @use:red-text", "Using red-text"),
        App.AddText("@use:combination @use:blue-text", "Using callback blue-text"),
        App.AddText("@use:combination @use:greenify", "Click to green!"),
        App.AddText("@use:nested-comb", "Directive Combination"),
        0
    )
}