class OptionParser {
    /**
     * Creates an option parser.
     * @param {Svaner} SvanerInstance 
     */
    __New(SvanerInstance) {
        this.svaner := SvanerInstance
        this.directiveCallbacks := Map()
        this.directiveOptionMap := Map(
            "@button:icon-only", " 0x40 0x300 ",
            "@text:align-center", " Center 0x200 ",
            "@pic:real-size", "0x40",
            "@lv:label-tip", "LV0x4000",
            "@lv:track-select", "LV0x8",
            "@dt:updown", "0x1",
            "@mc:week-numbers", "0x4",
            "@mc:no-today-circle", "0x8",
            "@mc:no-today", "0x10",
        )
    }

    /**
     * Evaluate options/directives.
     * @param {String} opt 
     * @returns {String} 
     * @throws {ValueError}
     */
    parseDirective(opt) {
        if (!StringExt.startsWith(opt, "@")) {
            ; ahk options
            return opt
        }
        else if (this.directiveOptionMap.Has(opt) && !(this.directiveOptionMap[opt] is Func)) {
            return this.directiveOptionMap[opt]
        }
        else if (StringExt.startsWith(opt, "@func:")) {
            return ""
        }
        else if (StringExt.startsWith(opt, "@align[") && InStr(opt, "]")) {
        ; else if (RegExMatch(opt, "^@Align(?!.*(.).*\1)[XYWH]+:.*$")) {
            splittedOpts := StrSplit(opt, ":")
            alignment := splittedOpts[1]
            targetCtrl := splittedOpts[2]
            
            this.svaner[targetCtrl].GetPos(&X, &Y, &Width, &Height)

            parsedPos := ""
            loop parse StringExt.replaceThese(alignment, ["@align[", "]"]), "" {
                switch StrUpper(A_LoopField) {
                    case "X":
                        parsedPos .= Format(" x{1} ", X)
                    case "Y":
                        parsedPos .= Format(" y{1} ", Y)
                    case "W":
                        parsedPos .= Format(" w{1} ", Width)
                    case "H":
                        parsedPos .= Format(" h{1} ", Height)
                }
            }

            return parsedPos
        }
        else { 
            throw ValueError("Unknown directive", -1, opt)
        }
    }
}