#SingleInstance Force
#Include "../useSvaner.ahk"

S := Svaner({
    gui: {
        options: "",
        title: A_ScriptName,
    },
    font: {
        fontOptions: "s12 bold",
        fontName: "Verdana"
    }
})

App(S)
S.Gui.Show()


/**
 * @param {Svaner} App 
 */
App(App) {
    greetMsg := signal("Hello, new AddReactive!") 

    handleGreetMsgUpdate(*) {
        greetMsg.set("A brand new start!")
        msgbox greetMsg.value
    }
    
    handleGetControl(*) {
        targetControl :=  App[ctrl => InStr(ctrl.Text, "Hello")]
        msgbox targetControl[1].Text
    }

    handleComponentShowHide(*) {
        comp := App["component:SomeComponent"]
        comp.visible(v => !v)
    }

    return (
        App.AddText("vtarget w200 h30 border", "{1}", greetMsg).onClick(handleGreetMsgUpdate),
        App.AddButton("@AlignWH:target", "get").onClick(handleGetControl),
        SomeComponent(App),
        App.AddButton("@AlignWH:target", "show/hide component!").onClick(handleComponentShowHide)
    )
}

/**
 * @param {Svaner} App 
 */
SomeComponent(App) {
    comp := Component(App, A_ThisFunc)

    comp.render := this => this.Add(
        App.AddText("@AlignWH:target", "from SomeComponent!"),
    )

    return comp.render()
}