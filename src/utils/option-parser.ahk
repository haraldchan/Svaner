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
     * Define custom directives.
     * @param {Map<string, ()=>void>} directiveDescriptor 
     */
    defineDirectives(directiveDescriptor) {
        for directive, optionsOrCallback in directiveDescriptor {
            if (!StringExt.startsWith(directive, "@")) {
                throw ValueError("Directive must starts with `"@`"", -1, directive)
            }

            StringExt.startsWith(directive, "@func:")
                ? this.directiveCallbacks[directive] := optionsOrCallback
                : this.directiveOptionMap[directive] := optionsOrCallback
        }
    }

    /**
     * Evaluate options/directives.
     * @param {String} opt 
     * @returns {String} 
     * @throws {ValueError}
     */
    parseDirective(opt) {
        ; native ahk options
        if (!StringExt.startsWith(opt, "@")) {
            ; ahk options
            return opt
        }
        ; func directive, ignore
        else if (StringExt.startsWith(opt, "@func:")) {
            return this.directiveCallbacks[opt]
        }
        ; string options
        else if (this.directiveOptionMap.Has(opt) && !(this.directiveOptionMap[opt] is Func)) {
            if (!InStr(this.directiveOptionMap[opt], "@")) {
                return Format(" {1} ", this.directiveOptionMap[opt])
            }

            parsed := ""
            loop parse this.directiveOptionMap[opt], " " {
                parsed .= Format(" {1} ", this.parseDirective(A_LoopField))
            }

            return parsed
        }
        ; align directive
        else if (StringExt.startsWith(opt, "@align[") && InStr(opt, "]")) {
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
        ; unknown
        else {
            throw ValueError("Unknown directive", -1, opt)
        }
    }
}