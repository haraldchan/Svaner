#SingleInstance Force
#Include "../useSvaner.ahk"

SvanerApp := Svaner({
    gui: {
        title: "Store VS Split Signal"
    },
    font: {
        name: "Tahoma"
    },
    events: {
        close: (*) => ExitApp()
    },
    devOpt: {
        ; border: true
        flashCtrlOnUpdate: true
    }
})

SVSS(SvanerApp)
SvanerApp.Show()

/**
 * @param {Svaner} App
 */
SVSS(App) {
    searchBy := signal("nameRoom")
    searchByMap := OrderedMap(
        "瀑流模式", "waterfall",
        "姓名/房号", "nameRoom",
        "证件号码", "idNum",
        "地址", "addr",
        "电话", "tel",
        "生日", "birthday",
        "时间戳 ID", "tsId",
    )

    queryFilter := signal(
        { date: A_Now, search: "nameRoom", range: 60 },
        { name: "query-filter" }
    )

    queryFilterStore := useStore("query-filter-store", {
        states: {
            date: A_Now,
            search: "nameRoom",
            range: 60
        }
    })

    handleDateUpdate(ctrl, _) {
        queryFilterStore.date.set(ctrl.Value)
    }

    handleSearchUpdate(ctrl, _) {
        queryFilterStore.search.set(searchByMap[ctrl.Text])
    }

    handleRangeUpdate(ctrl, _) {
        queryFilterStore.range.set(ctrl.Value)
    }

    handleQueryFilterSignalUpdate(ctrl, _) {
        switch ctrl.Name {
            case "date":
                queryFilter.update("date", ctrl.Value)
            case "search":
                queryFilter.update("search", searchByMap[ctrl.Text])
            case "range":
                queryFilter.update("range", ctrl.Value)
        }
    }

    standAloneDate := signal(A_Now, { name: "s-a-date" })

    triplet := signal({ a: "a", b: "b", c: "c"}, { name: "triplet" })


    render() {
        ; using store
        ; date
        App.AddDateTime("vdate-state", "yyyy-MM-dd").onChange(handleDateUpdate)
        ; search
        App.AddDDL("vsearch-state x+10 w80 Choose2", searchByMap.keys())
           .onChange(handleSearchUpdate)
        ; range
        App.AddText("x+10 h25 0x200", "最近")
        App.AddText("x+1 h25 0x200", "分钟")
        App.AddEdit("vrange-state Number x+1 w30 h25", "{1}", queryFilterStore.range).onChange(handleRangeUpdate)

        ; using signal
        ; date
        App.AddDateTime("vdate @align[x]:date-state y+5", "yyyy-MM-dd", standAloneDate).bind()
        ; search
        App.AddDDL("vsearch x+10 w80 Choose2", searchByMap.keys())
           .onChange(handleQueryFilterSignalUpdate)
        ; range
        App.AddText("x+10 h25 0x200", "最近")
        /**
         * notice difference of parameter:key.
         * if you use a function as key, it's just a getter and cannot use `bind`, you have to use `onChange`.
         * while using Array<key>, SvanerControl can use it to track the property, so use `bind` for two-way binding.
         */
        ; App.AddSlider("vrange x+1 w100 h25 ToolTip TickInterval Range-0-100", queryFilter, v => v.range).onChange(handleQueryFilterSignalUpdate)
        App.AddSlider("vrange x+1 w100 h25 ToolTip TickInterval Range-0-100", queryFilter, ["range"]).bind()
        App.AddText("x+1 h25 0x200", "分钟")


        ; binders
        App.AddEdit("@align[x]:date-state y+5 w80", "{1}", triplet, ["a"]).bind()
        App.AddEdit("w80 x+5", "{1}", triplet, ["b"]).bind()
        App.AddEdit("w80 x+5", "{1}", triplet, ["c"]).bind()
    }

    render()
}

DevToolsUI()