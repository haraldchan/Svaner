class OptionParser {
    __New(SvanerInstance) {
        this.Svaner := SvanerInstance
        this.Svaner.directives := this
        this.directiveOptionMap := Map(
            "@IconOnly", " 0x40 0x300 ",
            "@TextAlignCenter", " Center 0x200 ",
        )
    }

    /**
     * 
     * @param {String} opt 
     * @returns {Any | String} 
     * @throws {ValueError}
     */
    parseDirective(opt) {
        if (!StringExt.startsWith(opt, "@")) {
            ; ahk options
            return opt
        }
        if (this.directiveOptionMap.Has(opt)) {
            return this.directiveOptionMap[opt]
        }
        else if (StringExt.startsWith(opt, "@Align")) {
        ; else if (RegExMatch(opt, "^@Align(?!.*(.).*\1)[XYWH]+:.*$")) {
            splittedOpts := StrSplit(opt, ":")
            alignment := splittedOpts[1]
            targetCtrl := splittedOpts[2]
            
            this.Svaner[targetCtrl].GetPos(&X, &Y, &Width, &Height)

            parsedPos := ""
            loop parse StrReplace(alignment, "@Align", ""), "" {
                switch A_LoopField {
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