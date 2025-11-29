class Struct {
    /**
     * Creates predefined set of fields with specific data types.
     * ```
     * Person := Struct({
     *  name: String,
     *  age:  Integer,
     *  tel:  Number
     * })
     * ```
     * @param {Object} structObject An object defining the structure and data types for each field.
     */
    __New(structObject) {
        this.structObject := structObject
        this.typeMap := Map()

        for key, type in this.structObject.OwnProps() {
            this.typeMap[key] := type
        }
    }

    /**
     * Returns a Struct instance fulfills predefined data structure.
     * @param {Object|Map|OrderedMap} data 
     * ```
     * staff := Person.new({ 
     *   name: "Amy", 
     *   age:   29, 
     *   tel:   88372153
     * })
     * ```
     * @returns {Struct.StructInstance} 
     */
    new(data) {
        return Struct.StructInstance(data, this.typeMap)
    }

    class StructInstance {
        __New(data, typeMap) {
            this.data := data
            this.typeMap := typeMap
            this._keys := []
            this._values := []

            this.validateFields(data, typeMap)

            for key, val in (data is Map ? data : data.OwnProps()) {
                k := key
                v := val
                this._keys.Push(key)

                ; objects
                if (val.base == Object.Prototype || val is Map) {
                    this._values.Push(Struct.StructInstance(val, typeMap[key].typeMap))
                    continue
                }

                ; array of a certain type
                if (val is Array) {
                    ; array of same type values, e.g. [String]
                    if (!ArrayExt.every(val, item => item is typeMap[k][1])) {
                        throw TypeError(Format(
                            "Expected item type of index:{1} does not match.`n`nExpected: {2}, current: {3}",
                            ArrayExt.findIndex(val, item => Type(item) != typeMap[k][1]),
                            this.getTypeName(typeMap[k][1]),
                            Type(ArrayExt.find(val, item => Type(item) != typeMap[k][1]))
                        ))
                    }
                }
                ; primitive 
                if (val is Primitive) {
                    ; literal type
                    if (typeMap[k] is Primitive) {
                        if (val != typeMap[k]) {
                            errMsg := Format("Type mismatch.`n`nExpected: {1}, current: {2}", typeMap[k], val)
                            throw ValueError(errMsg, -1, val)
                        }
                    }
                    ; literal types
                    else if (typeMap[k] is Array && ArrayExt.every(typeMap[k], t => t is Primitive)) {
                        if (!ArrayExt.find(typeMap[k], item => item = v)) {
                            errMsg := Format("Type mismatch.`n`nAssignables: {1}", ArrayExt.join(typeMap[k], " | "))
                            throw ValueError(errMsg, -1, val)
                        }
                    }
                    else {
                        if (Type(val) != this.getTypeName(typeMap[k])) {
                            throw TypeError(Format(
                                "Expected value type of key:{1} does not match.`n`nExpected: {2}, current: {3}",
                                key,
                                this.getTypeName(typeMap[key]),
                                Type(val)
                            ))
                        }
                    }
                }

                this._values.Push(val)
            }
        }

        __Item[key] {
            get {
                if (!ArrayExt.find(this._keys, k => k = key)) {
                    throw ValueError(Format("Key:{1} not found.", key))
                }

                return this._values[ArrayExt.findIndex(this._keys, item => item = key)]
            }

            set {
                ; field not found
                if (!this._keys.find(k => k = key)) {
                    throw ValueError(Format("Key:`"{1}`" not found.", key))
                }

                ; object validation
                if (value.base == Object.Prototype || value is Map || value is Struct.StructInstance) {
                    matching := value is Struct.StructInstance
                        ? this.typeMap[key].new(value.mapify())
                        : this.typeMap[key].new(value)
                    matching := ""
                }
                ; array item validation
                else if (value is Array) {
                    if (this.typeMap[key] is Array && value.every(item => Type(item) != TypeChecker.getTypeName(this.typeMap[key][1]))) {
                        throw TypeError(Format(
                            "Expected item type of index:{1} does not match.`n`nExpected: {2}, current: {3}",
                            ArrayExt.findIndex(value, item => Type(item) != this.typeMap[key][1]),
                            this.getTypeName(this.typeMap[key][1]),
                            Type(ArrayExt.find(value, item => Type(item) != this.typeMap[key][1]))
                        ))
                    }
                }
                ; primitives
                else if (value is Primitive) {
                    ; literal type
                    if (this.typeMap[key] is Primitive) {
                        errMsg := Format("Type mismatch.`n`nExpected: {1}, current: {2}", this.typeMap[key], value)
                        throw ValueError(errMsg, -1, value)
                    }
                    ; literal types
                    else if (this.typeMap[key] is Array && ArrayExt.every(this.typeMap[key], t => t is Primitive)) {
                        if (!ArrayExt.find(this.typeMap[key], item => item = value)) {
                            errMsg := Format("Type mismatch.`n`nAssignables: {1}", ArrayExt.join(this.typeMap[key], " | "))
                            throw ValueError(errMsg, -1, value)
                        }
                    }
                    else {
                        if (Type(value) != TypeChecker.getTypeName(this.typeMap[key])) {
                            throw TypeError(Format(
                                "Expected value type of key:{1} does not match.`n`nExpected: {2}, current: {3}",
                                key,
                                this.getTypeName(this.typeMap[key]),
                                Type(value)
                            ))
                        }
                    }
                }

                this._values := this._values.with(this._keys.findIndex(item => item = key), value)
            }
        }

        __Enum(NumberOfVars) {
            return NumberOfVars == 1 ? enumK : enumKV

            enumK(&key) {
                if (A_Index > this._keys.Length) {
                    return false
                }

                key := this._keys[A_Index]
            }

            enumKV(&key, &value) {
                if (A_Index > this._keys.Length) {
                    return false
                }

                key := this._keys[A_Index]
                value := this._values[A_Index]
            }
        }

        getTypeName(classType) {
            if (classType is Struct) {
                return "Struct"
            }

            if (classType is Array) {
                itemType := this.getTypeName(classType[1])
                return "Array of " . itemType . "s"
            }

            switch classType {
                ; primitives
                case Number:
                    return "Number"
                case Integer:
                    return "Integer"
                case Float:
                    return "Float"
                case String:
                    return "String"

                    ; objects
                case Func:
                    return "Func"
                case Enumerator:
                    return "Enumerator"
                case Closure:
                    return "Closure"
                case Class:
                    return "Class"
                case Map:
                    return "Map"
                case Array:
                    return "Array"
                case Buffer:
                    return "Buffer"
                case ComObject:
                    return "ComObject"
                case Gui:
                    return "Gui"

                    ; AddReactive funcs
                case OrderedMap:
                    return "OrderedMap"

                    ; Object
                case Object:
                    return "Object"
            }
        }

        validateFields(data, typeMap) {
            errMsg := "Struct fields not match, {1}: `"{2}`""
            dataKeys := []

            if (data is Map) {
                dataKeys := MapExt.keys(data)
            } else if (data.base == Object.Prototype) {
                for key in data.OwnProps() {
                    dataKeys.Push(key)
                }
            }

            ; unknown field
            for key in dataKeys {
                if (!typeMap.has(key)) {
                    throw ValueError(Format(errMsg, "unknown", key))
                }
            }

            ; missing field
            for key, type in typeMap {
                k := key
                if (!ArrayExt.find(dataKeys, dKey => dKey = k)) {
                    throw ValueError(Format(errMsg, "missing", key))
                }
            }
        }

        /**
         * Returns a Map of converted StructInstance.
         * @returns {Map} 
         */
        mapify() {
            resMap := Map()

            for index, key in this._keys {
                val := this._values[index]
                resMap[key] := val is Struct.StructInstance ? val.mapify() : val
            }

            return resMap
        }

        /**
         * Returns a boolean indicating whether an element with the specified key exists in this struct instance or not.
         * @param key The key of the element to test for presence in the struct instance.
         * @returns {Boolean} true if an element with the specified key exists in the struct instance; otherwise false.
         */
        has(key) => ArrayExt.find(this._keys, item => item = key) ? true : false

        /**
         * Returns a JSON format string of converted StructInstance.
         * @returns {String} 
         */
        stringify() => JSON.stringify(this.mapify())
    }
}