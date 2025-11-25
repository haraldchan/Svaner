class Svaner {
    /**
     * Initialize a Svaner object.
     * ```
     * {
     *      gui: {
     *          options: "+AlwaysOnTop +Resize ...",
     *          title: A_ScriptName
     *      },
     *      font: {
     *          options: "s12 bold",
     *          name: "Tahoma"
     *      },
     *      events: {
     *          close: (thisGui) => thisGui.Destroy(),
     *          ; ...
     *      }
     * }
     * ```
     * @param configs 
     * @returns {Svaner}
     */
    __New(configs) {
        ; create gui
        this.gui := Gui(
            configs.gui.HasOwnProp("options") ? configs.gui.options : "",
            configs.gui.HasOwnProp("title") ? configs.gui.title : A_ScriptName,
        )

        if (configs.gui.HasOwnProp("events")) {
            for event, callback in configs.gui.events.OwnProps() {
                this.gui.OnEvent(event, callback)
            }
        }

        ; add svaner control map
        this.gui.scs := Map()
        this.gui.scs.Default := ""

        ; set font
        if (configs.HasOwnProp("font")) {
            this.gui.SetFont(
                configs.font.HasOwnProp("options") ? configs.font.options : "",
                configs.font.HasOwnProp("name") ? configs.font.name : ""
            )
        }

        ; components
        this.components := []

        ; add option parser
        this.optParser := OptionParser(this)
    }


    /**
     * 
     * @param {String | Func} ctrlSearchString 
     */
    __Item[ctrlSearchCondition] {
        get {
            if (ctrlSearchCondition is func) {
                return GuiExt.getCtrlsByMatch(this.gui, ctrlSearchCondition)
            }

            switch {
                ; by type
                case InStr(ctrlSearchCondition, "type:"):
                    return GuiExt.getCtrlByType(this.gui, StrReplace(ctrlSearchCondition, "type:", ""))

                    ; by type all
                case InStr(ctrlSearchCondition, "typeAll:"):
                    return GuiExt.getCtrlByTypeAll(this.gui, StrReplace(ctrlSearchCondition, "typeAll:", ""))

                    ; search component
                case InStr(ctrlSearchCondition, "component:"):
                    return GuiExt.getComponent(this, StrReplace(ctrlSearchCondition, "component:"))

                    ; by name
                default:
                    return GuiExt.getCtrlByName(this.gui, ctrlSearchCondition)
            }
        }
    }


    /**
     * Parse options/directives to native options.
     * @param {String} optionString 
     * @returns {String} 
     */
    __parseOptions(optionString) {
        parsed := ""
        splittedOptions := StrSplit(optionString, " ")

        for opt in splittedOptions {
            parsed .= this.optParser.parseDirective(opt) . " "
        }

        return parsed
    }

    /**
     * Apply custom directives to control.
     * @param {Svaner.Control | Gui.Control} control 
     * @param {String} options 
     */
    __applyCustomDirectives(control, options) {
        loop parse options, " " {
            if (this.optParser.directiveCallbacks.Has(A_LoopField)) {
                this.optParser.directiveCallbacks[A_LoopField](control)
            }
        }
    }


    /**
     * Sets various options and styles for the appearance and behavior of the gui window.
     * @param {String} options options apply to the gui window.
     */
    Opt(options) {
        this.gui.Opt(options)
    }


    /**
     * Show Gui window.
     * @param {String} options 
     */
    Show(options := "") => this.gui.Show(options)


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
                ? this.optParser.directiveCallbacks[directive] := optionsOrCallback
                : this.optParser.directiveOptionMap[directive] := optionsOrCallback
        }
    }


    /**
     * Add a Button/SvanerButton control to Gui.
     * @param {String} options Options/Directives apply to the control.
     * @param {String} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal.
     * @param {String|Array|Object} [key] the keys or index of the signal's value.
     * @returns {SvanerButton | Gui.Button} 
     */
    AddButton(options := "", content := "", depend?, key?) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := IsSet(depend) && depend is signal
            ? SvanerButton(this.gui, parsedOptions, content, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddButton(parsedOptions, content)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * Add a CheckBox/SvanerCheckBox control to Gui.
     * @param {String} options Options apply to the control, same as Gui.Add.
     * @param {string} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @returns {SvanerCheckBox | Gui.CheckBox} 
     */
    AddCheckBox(options, content := "", depend?, key?) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control :=  IsSet(depend) && depend is signal
            ? SvanerCheckBox(this.gui, parsedOptions, content, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddCheckbox(parsedOptions, content)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * 
     * @param options 
     * @param {signal|Array} dependOrList 
     * @param {String|Array|Object} [key] the keys or index of the signal's value.
     * @returns {SvanerComboBox | Gui.ComboBox} 
     */
    AddComboBox(options, dependOrList := [], key?) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control :=  dependOrList is signal
            ? SvanerComboBox(this.gui, parsedOptions, dependOrList, (IsSet(key) ? key : 0))
            : this.gui.AddComboBox(parsedOptions, dependOrList)
        this.__applyCustomDirectives(control, options)

        return control
    }

    /**
     * 
     * @param {String} options 
     * @param {String} dateFormat 
     * @returns {Gui.DateTime} 
     */
    AddDateTime(options, dateFormat := "ShortDate") {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := this.gui.AddDateTime(parsedOptions, dateFormat)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * 
     * @param options 
     * @param {signal | Array} dependOrList 
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerDropDownList | Gui.DDL} 
     */
    AddDropDownList(options, dependOrList, key?) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := dependOrList is signal
            ? SvanerDropDownList(this.gui, parsedOptions, dependOrList)
            : this.gui.AddDDL(parsedOptions, dependOrList)
        this.__applyCustomDirectives(control, options)

        return control
    }
    AddDDL(options, dependOrList, key?) => this.AddDropDownList(options, dependOrList, (IsSet(key) ? key : 0))


    /**
     * Add a Edit/SvanerEdit control to Gui.
     * @param {String} options Options/Directives apply to the control.
     * @param {String} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal.
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerEdit | Gui.Edit} 
     */
    AddEdit(options := "", content := "", depend?, key?) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := IsSet(depend) && depend is signal
            ? SvanerEdit(this.gui, parsedOptions, content, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddEdit(parsedOptions, content)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * Add a Edit/SvanerEdit control to Gui.
     * @param {String} options Options/Directives apply to the control.
     * @param {String} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal.
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerGroupBox | Gui.GroupBox} 
     */
    AddGroupBox(options, content := "", depend?, key?) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := IsSet(depend) && depend is signal
            ? SvanerGroupBox(this.gui, parsedOptions, content, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddGroupBox(parsedOptions, content)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * 
     * @param {String} options 
     * @returns {Gui.Hotkey} 
     */
    AddHotkey(options, hotkeyString) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := this.gui.AddHotkey(parsedOptions, hotkeyString)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * 
     * @param {String} options 
     * @param {String} text 
     * @returns {Gui.Link} 
     */
    AddLink(options, text) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options
        
        control := this.gui.AddLink(parsedOptions, text)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * 
     * @param {String} options 
     * @param {Array} list 
     * @returns {Gui.ListBox} 
     */
    AddListBox(options, list) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := this.gui.AddListBox(options, list)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * Add a ListView/SvanerListView control to Gui.
     * @param { {lvOptions: String[], itemOptions: String[]} | String} options Options/Directives apply to the control.
     * @param { {keys: String[], titles: String[], width: Number[]} | String[]} columnDetailsOrList 
     * @param {signal} [depend] Subscribed signal.
     * @param {String|Array|Object} [key] the keys or index of the signal's value.
     * @returns {SvanerListView | Gui.ListView}
     */
    AddListView(options, columnDetailsOrList, depend?, key?) {
        if (options is Object) {
            if (options.HasOwnProp("lvOptions")) {
                options.lvOptions := this.__parseOptions(options.lvOptions)
            }
            if (options.HasOwnProp("itemOptions")) {
                options.itemOptions := this.__parseOptions(options.itemOptions)
            }
        } else {
            parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options
        }

        control := IsSet(depend) && depend is signal
            ? SvanerListView(this.gui, options, columnDetailsOrList, depend, (IsSet(key) ? key : 0))
            : this.gui.AddListView(parsedOptions, columnDetailsOrList)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * 
     * @param {String} options 
     * @returns {Gui.MonthCal} 
     */
    AddMonthCal(options) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := this.gui.AddMonthCal(parsedOptions)
        this.__applyCustomDirectives(control, parsedOptions)

        return control
    }


    /**
     * Add a Picture/SvanerPicture control to Gui.
     * @param {String} options 
     * @param {signal | String} dependOrPicFilepath 
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerPicture | Gui.Pic} 
     */
    AddPicture(options, dependOrPicFilepath, key?) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := dependOrPicFilepath is signal
            ? SvanerPicture(this.gui, options, dependOrPicFilepath, (IsSet(key) ? key : 0))
            : this.gui.AddPicture(options, dependOrPicFilepath)
        this.__applyCustomDirectives(control, options)

        return control
    }
    AddPic(options, dependOrPicFilepath, key?) => this.AddPicture(options, dependOrPicFilepath, (IsSet(key) ? key : 0))


    /**
     * 
     * @param {String} options 
     * @param {Integer} startingPos 
     * @returns {Gui.Progress} 
     */
    AddProgress(options, startingPos := 0) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := this.gui.AddProgress(options, startingPos)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * Add a Radio/SvanerRadio control to Gui
     * @param {String} options Options/Directives apply to the control.
     * @param {String} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal.
     * @param {String | Array | Object} [key] the keys or index of the signal's value.
     * @returns {SvanerRadio | Gui.Radio} 
     */
    AddRadio(options, content := "", depend?, key?) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := IsSet(depend) && depend is signal
            ? SvanerRadio(this.gui, options, content, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddRadio(options, content)
        this.__applyCustomDirectives(control, options)
        
        return control
    }


    /**
     * 
     * @param {String} options 
     * @param {Integer} startingPos 
     * @returns {Gui.Slider} 
     */
    AddSlider(options, startingPos := 0) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := this.gui.AddSlider(options, startingPos)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * 
     * @param {String} options 
     * @param {String} startingText 
     * @returns {Gui.StatusBar} 
     */
    AddStatusBar(options := "", startingText := "") {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := this.gui.AddStatusBar(options, startingText)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * 
     * @param {String} options 
     * @param {String[]} pages 
     * @returns {Gui.Tab} 
     */
    AddTab3(options := "", pages := []) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := this.gui.AddTab3(options, pages)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * Add a Text control to Gui
     * @param {String} options Options/Directives apply to the control.
     * @param {String} content Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {String | Array | Object} [key] the keys or index of the signal's value
     * @returns {SvanerText | Gui.Text} 
     */
    AddText(options, content := "", depend?, key?) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := IsSet(depend) && depend is signal
            ? SvanerText(this.gui, parsedOptions, content, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddText(parsedOptions, content)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * Add a TreeView/SvanerTreeView control to Gui
     * @param {String} options Options/Directives apply to the control.
     * @param {signal} [depend] Subscribed signal
     * @param {String | Array | Object} [key] the keys or index of the signal's value
     * @returns {SvanerTreeView | Gui.TreeView} 
     */
    AddTreeView(options, depend?, key?) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := IsSet(depend) && depend is signal
            ? SvanerTreeView(this.gui, options, (IsSet(depend) ? depend : 0), (IsSet(key) ? key : 0))
            : this.gui.AddTreeView(options)
        this.__applyCustomDirectives(control, options)

        return control
    }


    /**
     * 
     * @param {String} options Options/Directives apply to the control.
     * @param {Integer} startingPos 
     * @returns {Gui.UpDown} 
     */
    AddUpDown(options, startingPos := 0) {
        parsedOptions := InStr(options, "@") ? this.__parseOptions(options) : options

        control := this.gui.AddUpDown(options, startingPos)
        this.__applyCustomDirectives(control, options)

        return control
    }


    ; Svaner Controls
    class Control {
        /**
         * Creates a new reactive control and add it to the window.
         * @param {Gui} GuiObject The target Gui Object.
         * @param {string} controlType Control type to create. Available: Text, Edit, CheckBox, Radio, DropDownList, ComboBox, ListView.
         * @param {string} options Options apply to the control, same as Gui.Add.
         * @param {string|Array|Object} content Text or formatted text for text, options for DDL/ComboBox, column option object for ListView.
         * @param {signal|Array|Object} depend Subscribed signal, or an array of signals. 
         * @param {string|number} key A key or index as render indicator.
         * @returns {Svaner} 
         */
        __New(GuiObject, controlType, options := "", content := "", depend := 0, key := 0) {
            this.GuiObject := GuiObject
            this.ctrlType := controlType
            this.options := options ? this._handleOptionsFormatting(options) : ""
            this.content := content ? content : ""
            this.depend := depend ? this._filterDepends(depend) : 0
            this.checkStatusDepend := ""
            this.key := key

            ; ListView options
            if (controlType == "ListView") {
                this.lvOptions := options.lvOptions
                this.itemOptions := options.HasOwnProp("itemOptions") ? options.itemOptions : ""
                this.checkedRows := []
            }

            ; TreeView options
            if (controlType == "TreeView") {
                this.tvOptions := options.tvOptions
                this.itemOptions := options.HasOwnProp("itemOptions") ? options.itemOptions : ""
            }

            ; textString handling
            if (controlType == "ComboBox" || controlType == "DropDownList") {
                if (depend.value is Array) {
                    this.optionTexts := depend.value
                } else if (depend.value is Map) {
                    this.optionTexts := MapExt.keys(depend.value)
                    this.optionsValues := MapExt.values(depend.value)
                }
            } else if (controlType == "ListView") {
                this.titleKeys := content.keys
                this.formattedContent := content.HasOwnProp("titles")
                    ? content.titles
                    : ArrayExt.map(this.titleKeys, key => (key is Array) ? key[key.Length] : key)
                this.colWidths := content.HasOwnProp("widths") ? content.widths : ArrayExt.map(this.titleKeys, item => "AutoHdr")
            } else {
                this.formattedContent := RegExMatch(content, "\{\d+\}") ? this._handleFormatStr(content, depend, key) : content
            }

            ; add control
            if (controlType == "ListView") {
                this.ctrl := this.GuiObject.Add(this.ctrlType, this.lvOptions, this.formattedContent)
                this._handleListViewUpdate()
                for width in this.colWidths {
                    this.ctrl.ModifyCol(A_Index, width)
                }
            } else if (controlType == "TreeView") {
                this.ctrl := this.GuiObject.AddTreeView(this.tvOptions)
                this.shadowTree := SvanerTreeView.ShadowTree(this.ctrl)
                this._handleTreeViewUpdate()
            }
            else if (controlType == "CheckBox" && this.HasOwnProp("checkValueDepend")) {
                this.ctrl := this.GuiObject.Add(this.ctrlType, this.options, this.formattedContent)
                this.ctrl.Value := this.checkValueDepend.value
                this.ctrl.OnEvent("Click", (ctrl, *) => this.checkValueDepend.set(ctrl.Value))
            }
            else if (controlType == "ComboBox" || controlType == "DropDownList") {
                this.ctrl := this.GuiObject.Add(this.ctrlType, this.options, this.optionTexts)
            }
            else {
                this.ctrl := this.GuiObject.Add(this.ctrlType, this.options, this.formattedContent)
            }
            this.ctrl.arcWrapper := this

            ; add subscribe
            if (!this.depend) {
                return
            } else if (this.depend is Array) {
                for dep in this.depend {
                    dep.addSub(this)
                }
            } else {
                this.depend.addSub(this)
            }
        }

        /**
         * Reformat options string to assign proper options for each control type.
         * @param {String} options 
         * @returns {String} formatted options string.
         */
        _handleOptionsFormatting(options) {
            if (this.ctrlType == "ListView") {
                optionsString := options.lvOptions
            } else if (this.ctrlType == "TreeView") {
                optionsString := options.tvOptions
            } else {
                optionsString := options
            }


            optionsArr := StrSplit(optionsString, " ")
            arcNameIndex := ArrayExt.findIndex(optionsArr, item => InStr(item, "$"))

            if (arcNameIndex) {
                this.name := optionsArr.RemoveAt(arcNameIndex)
                this.GuiObject.scs[this.name] := this
            }

            formattedOptions := ""
            for option in optionsArr {
                formattedOptions .= option . " "
            }

            if (this.ctrlType == "ListView") {
                options.lvOptions := formattedOptions
                return options
            } else if (this.ctrlType == "TreeView") {
                options.tvOptions := formattedOptions
                return options
            }

            return formattedOptions
        }

        /**
         * Filters checkValue for checks status binding with shared signal for ListView and CheckBox.
         * @param {signal|Object|Array} depend 
         */
        _filterDepends(depend) {
            if (depend is Array) {
                checkValueObject := ArrayExt.find(depend, d => d is Object && d.HasOwnProp("checkValue"))
                if (checkValueObject != "") {
                    this.checkValueDepend := (depend.RemoveAt(
                        ArrayExt.findIndex(depend, d => d is Object && d.HasOwnProp("checkValue"))
                    )).checkValue
                    this.checkValueDepend.addSub(this)
                }
                return depend
            } else if (depend is Object && depend.HasOwnProp("checkValue")) {
                this.checkValueDepend := depend.checkValue
                this.checkValueDepend.addSub(this)
                return 0
            } else {
                return depend
            }
        }

        /**
         * Updates text content of the control with latest signal value.
         * @param {String} formatStr Text content of the control in format string form.
         * @param {signal} depend depend signal.
         * @param {Number|Array} key A index for Array of key for an Object value of depend signal.
         */
        _handleFormatStr(formatStr, depend, key) {
            vals := []

            if (!key) {
                this._fmtStr_handleKeyless(depend, vals)
            } else if (key is Number) {
                this._fmtStr_handleKeyNumber(depend, key, vals)
            } else if (key is Func) {
                this._fmtStr_handleKeyFunc(depend, key, vals)
            } else {
                this._fmtStr_handleKeyObject(depend, key, vals)
            }

            return Format(formatStr, vals*)
        }
        _fmtStr_handleKeyless(depend, vals) {
            if (!depend) {
                return
            }

            if (depend is Array) {
                for dep in depend {
                    vals.Push(dep.value)
                }
            } else if (depend.value is Array) {
                vals := depend.value
            } else {
                vals.Push(depend.value)
            }
        }
        _fmtStr_handleKeyNumber(depend, key, vals) {
            for item in depend.value {
                vals.Push(depend.value[key])
            }
        }
        _fmtStr_handleKeyFunc(depend, key, vals) {
            vals.Push(key(depend.value))
        }
        _fmtStr_handleKeyObject(depend, key, vals) {
            if (key.base == Object.Prototype) {
                index := key.HasOwnProp("index") ? key.index : A_Index

                for k in key.keys {
                    vals.Push(k is Func ? k(depend.value[index]) : depend.value[index][k])
                }
            } else {
                for k in key {
                    vals.Push(k is Func ? k(depend.value) : depend.value[k])
                }
            }
        }

        /**
         * Updates ListView items with latest signal value.
         */
        _handleListViewUpdate() {
            this.ctrl.Delete()

            for item in this.depend.value {
                ; item -> Object || Map || OrderedMap
                if (item.base == Object.Prototype) {
                    itemIn := JSON.parse(JSON.stringify(item))
                } else if (item is Map) {
                    itemIn := item
                }

                rowData := ArrayExt.map(this.titleKeys, key => getRowData(key, itemIn))
                getRowData(key, itemIn, layer := 1) {
                    if (key is String) {
                        if (itemIn.Has(key)) {
                            return itemIn[key]
                        } else {
                            return this._listview_getFirstMatch(key, itemIn)
                        }
                    }

                    if (key is Array) {
                        return this._listview_getExactMatch(key, itemIn, 1)
                    }
                }

                this.ctrl.Add(this.itemOptions, rowData*)
            }

            this.ctrl.Modify(1, "Select")
            this.ctrl.Focus()


        }
        _listview_getExactMatch(keys, item, index) {
            if !(item is Map) {
                return item
            }

            return this._listview_getExactMatch(keys, item[keys[index]], index + 1)
        }
        _listview_getFirstMatch(key, item) {
            if (item.Has(key)) {
                return item[key]
            }

            for k, v in item {
                if (v is Map) {
                    res := this._listview_getFirstMatch(key, v)
                    if (res != "") {
                        return res
                    }
                }
            }
        }

        /**
         * Updates TreeView items with latest signal value.
         */
        _handleTreeViewUpdate() {
            this.ctrl.Delete()
            this.shadowTree.copy(this.depend.value)

            itemId := 0
            loop {
                itemId := this.ctrl.GetNext(itemId, "Full")
                if (!itemId) {
                    break
                }

                this.ctrl.Modify(itemId, this.itemOptions)
            }

            this.ctrl.Modify(this.ctrl.GetNext(0, "Full"), "Select")
        }

        /**
         * Interface for signal too call and updating control contents.
         * @param {signal} signal The subscribed signal
         */
        update(signal) {
            if (this.ctrl is Gui.Edit) {
                ; update text value
                this.ctrl.Value := this._handleFormatStr(this.content, this.depend, this.key)
                return
            }

            if (this.ctrl is Gui.ListView) {
                ; update from checkStatusDepend
                if (this.checkStatusDepend == signal) {
                    this.ctrl.Modify(0, this.checkStatusDepend.value == true ? "-Checked" : "+Checked")
                    return
                }
                ; update list items
                this._handleListViewUpdate()
                return
            }

            if (this.ctrl is Gui.TreeView) {
                this._handleTreeViewUpdate()
                return
            }

            if (this.ctrl is Gui.CheckBox) {
                ; update from checkStatusDepend
                if (this.checkStatusDepend == signal) {
                    this.ctrl.Value := this.CheckStatusDepend.value
                    return
                }
                ; update text label
                this.ctrl.Text := this._handleFormatStr(this.content, this.depend, this.key)
                if (this.HasOwnProp("checkValueDepend")) {
                    this.ctrl.Value := this.checkValueDepend.Value
                }
                return
            }

            if (this.ctrl is Gui.ComboBox || this.ctrl is Gui.DDL) {
                ; replace the list content
                this.ctrl.Delete()
                this.ctrl.Add(signal.value is Array ? signal.value : MapExt.keys(signal.value))
                this.ctrl.Choose(1)
                if (signal.value is Array) {
                    this.optionTexts := signal.value
                } else {
                    this.optionsTexts := MapExt.keys(signal.value)
                    this.optionsValues := MapExt.values(signal.value)
                }
                return
            }

            if (this.ctrl is Gui.Pic) {
                try {
                    this.ctrl.Value := signal.value
                }
                return
            }

            ; update text label
            this.ctrl.Text := this._handleFormatStr(this.content, this.depend, this.key)

        }

        ; APIs
        /**
         * Sets a depend signal for Svaner Control.
         * @param {Signal} depend 
         */
        SetDepend(depend) {
            this.depend := this._filterDepends(depend)
            this.update(this.depend)

            return this
        }

        setKey(newKey) {
            this.key := newKey
            this.update(this.depend)

            return this
        }


        /**
         * Registers one or more functions to be call when given event is raised. 
         * @param {<String, Func>} event key-value pairs of event-callback.
         * ```
         * ; single event
         * Svaner.Control.OnEvent("Click", (*) => (...))
         * 
         * ; multiple events
         * Svaner.Control.OnEvent(
         *   "Click", (*) => (...), 
         *   "DoubleClick", (*) => (...)
         * )
         * 
         * ```
         * @returns {Svaner.Control} 
         */
        OnEvent(event*) {
            loop event.Length {
                if (Mod(A_Index, 2) == 0) {
                    continue
                }

                this.ctrl.OnEvent(event[A_Index], event[A_Index + 1])
            }

            return this
        }

        /**
         * Registers a function to be call when "Change" event is raised.
         * @param eventCallback The callback function when event is raised.
         * @returns {Svaner.Control} 
         */
        onChange(eventCallback) {
            this.ctrl.OnEvent("Change", eventCallback)

            return this
        }

        /**
         * Registers a function to be call when "Click" event is raised.
         * @param eventCallback The callback function when event is raised.
         * @returns {Svaner.Control} 
         */
        onClick(eventCallback) {
            this.ctrl.OnEvent("Click", eventCallback)

            return this
        }

        /**
         * Registers a function to be call when "DoubleClick" event is raised.
         * @param eventCallback The callback function when event is raised.
         * @returns {Svaner.Control} 
         */
        onDoubleClick(eventCallback) {
            this.ctrl.OnEvent("DoubleClick", eventCallback)

            return this
        }

        /**
         * Registers a function to be call when "ColClick" event is raised.
         * @param eventCallback The callback function when event is raised.
         * @returns {Svaner.Control} 
         */
        onColClick(eventCallback) {
            this.ctrl.OnEvent("ColClick", eventCallback)

            return this
        }

        /**
         * Registers a function to be call when "ContextMenu" event is raised.
         * @param eventCallback The callback function when event is raised.
         * @returns {Svaner.Control} 
         */
        onContextMenu(eventCallback) {
            this.ctrl.OnEvent("ContextMenu", eventCallback)

            return this
        }

        /**
         * Registers a function to be call when "Focus" event is raised.
         * @param eventCallback The callback function when event is raised.
         * @returns {Svaner.Control} 
         */
        onFocus(eventCallback) {
            this.ctrl.OnEvent("Focus", eventCallback)

            return this
        }

        /**
         * Registers a function to be call when "LoseFocus" event is raised.
         * @param eventCallback The callback function when event is raised.
         * @returns {Svaner.Control} 
         */
        onBlur(eventCallback) {
            this.ctrl.OnEvent("LoseFocus", eventCallback)

            return this
        }

        /**
         * Registers a function to be call when "ItemCheck" event is raised.
         * @param eventCallback The callback function when event is raised.
         * @returns {Svaner.Control} 
         */
        onItemCheck(eventCallback) {
            this.ctrl.OnEvent("ItemCheck", eventCallback)

            return this
        }

        /**
         * Registers a function to be call when "ItemEdit" event is raised.
         * @param eventCallback The callback function when event is raised.
         * @returns {Svaner.Control} 
         */
        onItemEdit(eventCallback) {
            this.ctrl.OnEvent("ItemEdit", eventCallback)

            return this
        }

        /**
         * Registers a function to be call when "ItemExpand" event is raised.
         * @param eventCallback The callback function when event is raised.
         * @returns {Svaner.Control} 
         */
        onItemExpand(eventCallback) {
            this.ctrl.OnEvent("ItemExpand", eventCallback)

            return this
        }

        /**
         * Registers a function to be call when "ItemFocus" event is raised.
         * @param eventCallback The callback function when event is raised.
         * @returns {Svaner.Control} 
         */
        onItemFocus(eventCallback) {
            this.ctrl.OnEvent("ItemFocus", eventCallback)

            return this
        }

        /**
         * Registers a function to be call when "ItemSelect" event is raised.
         * @param eventCallback The callback function when event is raised.
         * @returns {Svaner.Control} 
         */
        onItemSelect(eventCallback) {
            this.ctrl.OnEvent("ItemSelect", eventCallback)

            return this
        }


        /**
         * Sets various options and styles for the appearance and behavior of the control.
         * @param newOptions Specify one or more control-specific or general options and styles, each separated from the next with one or more spaces or tabs.
         */
        Opt(newOptions) {
            this.ctrl.Opt(newOptions)
            return this
        }

        /**
         * Sets the font typeface, size, style, and/or color for controls added to the window from this point onward.
         * ```
         * SvanerText("...", "Text").SetFont("cRed s12", "Arial")
         * ```
         * @param {String} options Font options. C: color, S: size, W: weight, Q: quality
         * @param {String} fontName Name of font to set. 
         */
        SetFont(options := "", fontName := "") {
            this.ctrl.SetFont(options, fontName)
            return this
        }

        /**
         * Sets the font reactively with depend signal and option map.
         * ```
         * color := signal("red")
         * options := Map(
         *  "red", "cRed"
         *  "blue", "cBlue"
         *  "green", "cGreen"
         * )
         * 
         * SvanerText("...", "Text").SetFontStyles(options, color)
         * ; or
         * SvanerText("...", "{1}", color).SetFontStyles(options)
         * ```
         * @param {Map} optionMap A Map with depend signal value as keys, font options as values
         * @param {Signal} [depend] Signal dependency. If omitted, it will use the Svaner.Control.depend instead.
         */
        SetFontStyles(optionMap, depend := this.depend) {
            ; checkType(optionMap, Map)
            ; checkType(depend, signal)

            effect(depend, cur => this.ctrl.SetFont(optionMap.has(cur) ? optionMap[cur] : optionMap["default"]))
            return this
        }

        /**
         * Sets keyboard focus to the control.
         */
        Focus() {
            this.ctrl.Focus()
            return this
        }
    }
}