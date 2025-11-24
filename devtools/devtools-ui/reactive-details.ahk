; TODO:
/**
 * Pt. Dynamic Control for different type of value
 *  - String|Number: Edit
 *  
 *  - Object|Map|Array<String|Number>: 2-col ListView for key/val or index/val
 *  
 *  - Array<Object|Map>: multi-col ListView
 * 
 * Pt. Hence, needs a type validating func, perhaps Struct.New is useful.
 */

/**
 * @param {Map} debuggerMap
 */
ReactiveDetails(debuggerMap) {
    RD := Svaner({
        gui: { 
            title: debuggerMap["signalName"] 
        },
        font: { 
            name: "Tahoma" 
        }
    })

    valueToShow := debuggerMap["debugger"].value["signalInstance"].value is Object
        ? JSON.stringify(debuggerMap["debugger"].value["signalInstance"].value)
        : debuggerMap["debugger"].value["signalInstance"].value

    return (
        RD.AddText("w200 h200", valueToShow),

        RD.Show()
    )
}