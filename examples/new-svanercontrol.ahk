#SingleInstance Force
#Include "../useSvaner.ahk"

SvanerApp := Svaner({
    gui: {
        title: "Some controls"
    },
    font: {
        name: "Tahoma"
    },
    events: {
        close: (*) => ExitApp()
    }
})
NewSvanerControl(SvanerApp)
SvanerApp.Show()

/**
 * @param {Svaner} App
 */
NewSvanerControl(App) {
    sliderVal := signal(0)
    
    handleSliderValUpdate(ctrl, _) => sliderVal.set(ctrl.Value)
    
    linkClick(ctrl, id, href) {
        msgText := Format("
        (
            ID: {1}
            HREF: {2}

            Execute this link?
        )", id, href)
        if (MsgBox(msgText,, "y/n") = "yes")
            Run(href)
    }

    dateTime := signal("202511112022")
    handleDateTimeUpdate(ctrl, _) {
        dateTime.set(ctrl.Value)
    }

    return (
        ; clearer link
        App.AddLink("w300 h25", "This is a {1}", { text: "link", href: "https://www.autohotkey.com"}),
        App.AddLink(
            "w300 h25", 
            "Click to run {1} or open {2}", 
            [
                { text: "Notepad", id: "notepad", href: "notepad" }, 
                { text: "online help", id: "help", href: "https://www.autohotkey.com/docs/" }
            ]
        ).onClick(linkClick),

        ; slider
        App.AddEdit("w300 h25 Number", "{1}", sliderVal).onChange(handleSliderValUpdate),
        App.AddSlider("ToolTip TickInterval Range-10-10 w300 h25", sliderVal).onChange(handleSliderValUpdate),

        ; DateTime/MonthCal
        App.AddDateTime("","yyyy/MM/dd HH:ss", dateTime).onChange(handleDateTimeUpdate),
        App.AddMonthCal("vcalendar", dateTime).onChange(handleDateTimeUpdate),
        0
    )
}