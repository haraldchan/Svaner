class useListPlaceholder {
    /**
     * Set placeholder value for AddReactive ListView such as loading or error.
     * @param {signal} signal Signal that provides list content.
     * @param {Object | Array} columnDetails An object or Array containing the keys for column values.
     * @param {String} placeHolder Text as placeholder.
     */
    __New(_signal, columnDetails, placeholder) {
        TypeChecker.checkType(_signal, signal, "First Parameter is not a signal.")
        TypeChecker.checkType(_signal.value, Array, "useListPlaceholder can only work with Array signals.")
        TypeChecker.checkType(columnDetails, [Object, Array], "Second Parameter is not an Object.")
        TypeChecker.checkType(placeholder, String, "Third Parameter is not an String.")

        this.columnKeys := ((columnDetails is Object) && !(columnDetails is Array)) 
            ? columnDetails.keys 
            : columnDetails
        this.placeHolder := placeholder

        _signal.set([this._setLoadingValue()])
    }

    _setLoadingValue() {
        loadingValue := OrderedMap()

        for key in this.columnKeys {
            loadingValue[key] := this.placeHolder
        }

        return loadingValue
    }
}