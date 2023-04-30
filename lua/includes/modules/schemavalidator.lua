---@class SchemaType
---@field name string
---@field Validate fun(self: SchemaType, value: any): (boolean, string)
---@field Optional fun(self: SchemaType): SchemaType

---@class SchemaTypeWithSubType : SchemaType
---@field type SchemaType

SchemaValidator = {}

---@param valueType SchemaType
---@return SchemaTypeWithSubType
function SchemaValidator.Optional( valueType )
    return {
        type = valueType,
        name = "optional",
        Validate = function( self, value )
            if value == nil then
                return true, ""
            end

            return self.type:Validate( value )
        end
    }
end

---@return SchemaType
function SchemaValidator.Bool()
    return {
        name = "bool",
        Optional = function( self )
            return SchemaValidator.Optional( self )
        end,
        Validate = function( _, value )
            if type( value ) ~= "boolean" then
                return false, "value must be a boolean but was " .. type( value )
            end

            return true, ""
        end
    }
end

---@class SchemaTypeNumber : SchemaType
---@field min? number
---@field max? number
--
---@param opts { min: number, max: number }
---@return SchemaTypeNumber
function SchemaValidator.Int( opts )
    return {
        name = "int",
        min = opts.min,
        max = opts.max,
        Optional = function( self )
            return SchemaValidator.Optional( self )
        end,
        Validate = function( self, value )
            if type( value ) ~= "number" then
                return false, "value must be a number but was " .. type( value )
            end

            if math.floor( value ) ~= value then
                return false, "value must be an integer"
            end

            if self.min and value < self.min then
                return false, "value must be greater than or equal to " .. self.min
            end

            if self.max and value > self.max then
                return false, "value must be less than or equal to " .. self.max
            end

            return true, ""
        end
    }
end

---@class SchemaTypeObject: SchemaType
---@field ValidateField fun(self: SchemaTypeObject, key: any, value: any): (boolean, string)
---@field fields { [string]: SchemaType }

---@param tbl { [string]: SchemaType }
---@return SchemaTypeObject
function SchemaValidator.Object( tbl )
    return {
        fields = tbl,
        name = "table",
        Optional = function( self )
            return SchemaValidator.Optional( self )
        end,
        ValidateField = function( self, key, value )
            local fieldType = self.fields[key]
            if not fieldType then
                return false, "key " .. key .. " is not in in object"
            end

            local ok, err = fieldType:Validate( value )
            if not ok then
                return false, "key " .. key .. " " .. err
            end

            return true, ""
        end,
        Validate = function( self, value )
            if type( value ) ~= "table" then
                return false, "value must be a table but was " .. type( value )
            end

            for key, fieldType in pairs( self.fields ) do
                local ok, err = fieldType:Validate( value[key] )
                if not ok then
                    return false, "key " .. key .. " " .. err
                end
            end

            return true, ""
        end
    }
end

---@param t SchemaType
---@return SchemaType
function SchemaValidator.List( t )
    return {
        type = t,
        name = "list",
        Optional = function( self )
            return SchemaValidator.Optional( self )
        end,
        Validate = function( self, value )
            if type( value ) ~= "table" then
                return false, "value must be a table but was " .. type( value )
            end

            for i, val in ipairs( value ) do
                local ok, err = self.type:Validate( val )
                if not ok then
                    return false, "index " .. i .. " " .. err
                end
            end

            return true, ""
        end
    }
end

---@param keyType SchemaType
---@param valueType SchemaType
---@return SchemaType
function SchemaValidator.Map( keyType, valueType )
    return {
        keyType = keyType,
        type = valueType,
        name = "map",
        Optional = function( self )
            return SchemaValidator.Optional( self )
        end,
        Validate = function( self, value )
            if type( value ) ~= "table" then
                return false, "value must be a table but was " .. type( value )
            end

            for key, val in pairs( value ) do
                local keyOk, keyErr = self.keyType:Validate( key )
                if not keyOk then
                    return false, "key " .. key .. " " .. keyErr
                end

                local valueOk, valueErr = self.type:Validate( val )
                if not valueOk then
                    return false, "key " .. key .. " " .. valueErr
                end
            end

            return true, ""
        end
    }
end

---@param opts? { min: number, max: number }
---@return SchemaTypeNumber
function SchemaValidator.Number( opts )
    opts = opts or {}
    return {
        name = "number",
        min = opts.min,
        max = opts.max,
        Optional = function( self )
            return SchemaValidator.Optional( self )
        end,
        Validate = function( self, value )
            if type( value ) ~= "number" then
                return false, "value must be a number but was " .. type( value )
            end
            if self.min and value < opts.min then
                return false, "value must be greater than or equal to " .. self.min
            end

            if self.max and value > opts.max then
                return false, "value must be less than or equal to " .. self.max
            end


            return true, ""
        end
    }
end

---@return SchemaType
function SchemaValidator.String()
    return {
        name = "string",
        Optional = function( self )
            return SchemaValidator.Optional( self )
        end,
        Validate = function( _, value )
            if type( value ) ~= "string" then
                return false, "value must be a string but was " .. type( value )
            end

            return true, ""
        end
    }
end
