#SingleInstance Force
#Include "../useSvaner.ahk"

SvanerApp := Svaner({
    gui: {
        title: "No Mapify"
    },
    font: {
        name: "Tahoma"
    },
    events: {
        close: (*) => ExitApp()
    }
})
NoMapify(SvanerApp)
SvanerApp.Show()

/**
 * @param {Svaner} App
 */
NoMapify(App) {
    count := signal(0, { name: "count" })

    doubleCount := computed(count, cur => cur * 2, { name: "doubleCount" })

    sum := computed([count, doubleCount], (curCount, curDoubled) => curCount + curDoubled, { name: "sum" })

    numbers := computed([count, doubleCount, sum], (c,d,s) => { count: c, doubled: d, sum: s }, { name: "numbers" })

    handleIncrement(*) {
        count.set(c => c + 1)
    }


    staffList := signal([
        { name: "harald", pos: "attendant", contact: { tel: 98284858 } },
        { name: "amy", pos: "supervisor", contact: { tel: 5324525 } },
        { name: "leon", pos: "manager", contact: { tel:32942392 } }
    ], { name: "staffList" })

    showAmy(*) {
        msgbox staffList.value[2].name
    }

    updateAmy(*) {
        newAmyInfo := staffList.value.find(item => item.name == "amy")
        newAmyInfo.pos := "director"
        staffList.update(staffList.value.findIndex(item => item.name == "amy"), newAmyInfo)
    }

    return (
        App.AddText("vcounter @text:align-center w200 h30", "current count: {1}", count),
        App.AddText("@align[WH]:counter @text:align-center", "doubled count: {1}", doubleCount),
        App.AddText("@align[WH]:counter @text:align-center", "Sum: {1}", sum),
        App.AddButton("@align[WH]:counter", "counter++")
           .onClick(handleIncrement)
        
        ; staffList.value.map(staff => (
        ;     App.AddText(
        ;         "w300 h20", 
        ;         "name: {1}, pos: {2}, tel: {3}", 
        ;         staffList, 
        ;         { index: A_Index, keys: ["name", "pos", v => v.contact.tel] }
        ;     )
        ; )),

        ; App.AddButton("w200 h20", "update amy").onClick(updateAmy)
    )
}

DevToolsUI()