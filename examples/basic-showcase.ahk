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
Counter(SvanerApp)
SvanerApp.Show()

/**
 * @param {Svaner} App 
 */
Counter(App) {
    count := signal(0, { name: "count" })

    doubleCount := computed(count, cur => cur * 2, { name: "doubleCount" })

    sum := computed([count, doubleCount], (curCount, curDoubled) => curCount + curDoubled, { name: "sum" })

    numbers := computed([count, doubleCount, sum], (c,d,s) => Map("count", c, "doubled", d, "sum", s ), { name: "numbers" })

    handleIncrement(*) {
        count.set(c => c + 1)
    }

    return (
        App.AddText("vcounter @text:align-center w200 h30", "current count: {1}", count),
        App.AddText("@align[WH]:counter @text:align-center", "doubled count: {1}", doubleCount),
        App.AddText("@align[WH]:counter @text:align-center", "Sum: {1}", sum),
        App.AddButton("@align[WH]:counter", "counter++")
           .onClick(handleIncrement)
    )
}

DevToolsUI()