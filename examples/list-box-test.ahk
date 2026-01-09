#SingleInstance Force
#Include "../useSvaner.ahk"

SvanerApp := Svaner({
    gui: {
        title: "ListBox"
    },
    font: {
        name: "Tahoma"
    },
    events: {
        close: (*) => ExitApp()
    }
})
ListBoxTest(SvanerApp)
SvanerApp.Show()

/**
 * @param {Svaner} App 
 */
ListBoxTest(App) {
    list := signal(Map(
        "a", "this is a",
        "b", "this is b",
        "c", "this is c",
    ))

    showListItem(ctrl, _) {
        msgbox(list.value[ctrl.Text])
    }



    return (
        ; App.AddListBox("", ["a", "b", "c"]).onChange(showListItem)
        App.AddListBox("vlb", list).onChange(showListItem)
    )
}