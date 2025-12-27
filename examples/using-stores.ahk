#SingleInstance Force
#Include "../useSvaner.ahk"

countStore := useStore("count-store", {
    states: {
        count: 0
    },
    deriveds: {
        doubled: this => this.count.value * 2,
    },
    methods: {
        showAdd: (this, msg := "") => MsgBox(Format("{1}{2}", msg, this.count.value + this.doubled.value))
    }
})

SvanerApp := Svaner({
    gui: {
        title: "Using Stores"
    },
    font: {
        options: "s10",
        name: "Tahoma"
    },
    events: {
        close: (*) => ExitApp()
    }
})
UsingStores(SvanerApp)
SvanerApp.Show()

/**
 * @param {Svaner} App 
 */
UsingStores(App) {
    unpack(countStore, {
        count: &count,
        doubled: &doubled,
        methods: {
            showAdd: &showAdd
        }
    })

    return (
        App.AddText("w200 h25", "count: {1}", count),
        App.AddText("w200 h25", "doubled: {1}", doubled),

        App.AddButton("w200 h25", "count++").onClick((*) => count.set(n => n + 1)),
        App.AddButton("w200 h25", "Method Add").onClick((*) => showAdd("sum: "))

        ; without using unpack
        ; App.AddText("w200 h25", "count: {1}", countStore.count),
        ; App.AddText("w200 h25", "doubled: {1}", countStore.doubled),

        ; App.AddButton("w200 h25", "count++").onClick((*) => countStore.count.set(n => n + 1)),
        ; App.AddButton("w200 h25", "Method Add").onClick((*) => countStore.useMethod("showAdd")("sum: "))
    )
}

DevToolsUI()