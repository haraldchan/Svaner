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
UsingChildren(SvanerApp)
SvanerApp.Show()

/**
 * @type {Svaner} App
 */
UsingChildren(App) {
    c := signal(1)

    cComponents := Map(
        1, (*) => Parent_1(App, { children: (c) => Child_1(App, c.name), red: " cRed" }),
        2, (*) => Parent_2(App, { children: (c) => Child_2(App) }),
        3, Parent_3
    )

    return (
        Dynamic(App, c, cComponents, { style: "w200 h25", blue: " cBlue " }),
        App.AddSlider("w200 y+100 range1-3", c).onChange((ctrl, _) => c.set(ctrl.Value))
    )
}

Parent_1(App, props) {
    comp := Component(App, A_ThisFunc, props)

    comp.render := this => this.Add(
        App.AddText("vfirst-line" . props.style . props.red, "P1 before child"),
        this.children(),
        App.AddText(props.style . props.blue, "P1 after child"),
    )

    return comp
}

class Parent_2 extends Component {
    __New(App, props) {
        this.App := App
        super.__New(App, this.__Class, props)
    }

    render() => this.Add(
        this.App.AddText("@align[xy]:first-line" . this.props.style, "P2 before child"),
        this.children(),
        this.App.AddText(this.props.style . this.props.blue, "P2 after child"), 
    )
}

Parent_3(App, props) {
    comp := Component(App, A_ThisFunc)

    comp.render := this => this.Add(
        App.AddText("@align[xy]:first-line" . props.style, "Just P3"),
    )

    return comp
}

Child_1(App, name) {
    return App.AddText("w200 h25", "this is the child " . name)
}

Child_2(App) {
    return App.AddText("w200 h25", "this is the child of Parent 2")
}