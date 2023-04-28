---@class SchemaType
---@field name string
---@field Validate fun(self: SchemaType, value: any): (boolean, string)
---@field Optional fun(self: SchemaType): SchemaType


SchemaValidator = {}

---@param valueType SchemaType
---@return SchemaType
function SchemaValidator.Optional( valueType )
    return {
        _type = valueType,
        name = "Optional",
        Validate = function( self, value )
            if value == nil then
                return true, ""
            end

            return self._type:Validate( value )
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

---@param opts { min: number, max: number }
---@return SchemaType
function SchemaValidator.Int( opts )
    return {
        name = "int",
        Optional = function( self )
            return SchemaValidator.Optional( self )
        end,
        Validate = function( _, value )
            if type( value ) ~= "number" then
                return false, "value must be a number but was " .. type( value )
            end

            if math.floor( value ) ~= value then
                return false, "value must be an integer"
            end

            if opts.min and value < opts.min then
                return false, "value must be greater than or equal to " .. opts.min
            end

            if opts.max and value > opts.max then
                return false, "value must be less than or equal to " .. opts.max
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
            local type = self.fields[key]
            if not type then
                return false, "key " .. key .. " is not in in object"
            end

            local ok, err = type:Validate( value )
            if not ok then
                return false, "key " .. key .. " " .. err
            end

            return true, ""
        end,
        Validate = function( self, value )
            if type( value ) ~= "table" then
                return false, "value must be a table but was " .. type( value )
            end

            for key, type in pairs( self.fields ) do
                local ok, err = type:Validate( value[key] )
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
        _type = t,
        name = "list",
        Optional = function( self )
            return SchemaValidator.Optional( self )
        end,
        Validate = function( self, value )
            if type( value ) ~= "table" then
                return false, "value must be a table but was " .. type( value )
            end

            for i, val in ipairs( value ) do
                local ok, err = self._type:Validate( val )
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
        _keyType = keyType,
        _type = valueType,
        name = "map",
        Optional = function( self )
            return SchemaValidator.Optional( self )
        end,
        Validate = function( self, value )
            if type( value ) ~= "table" then
                return false, "value must be a table but was " .. type( value )
            end

            for key, val in pairs( value ) do
                local ok, err = self._keyType:Validate( key )
                if not ok then
                    return false, "key " .. key .. " " .. err
                end

                local ok, err = self._type:Validate( val )
                if not ok then
                    return false, "key " .. key .. " " .. err
                end
            end

            return true, ""
        end
    }
end

---@param opts? { min: number, max: number }
---@return SchemaType
function SchemaValidator.Number( opts )
    opts = opts or {}
    return {
        name = "number",
        Optional = function( self )
            return SchemaValidator.Optional( self )
        end,
        Validate = function( _, value )
            if type( value ) ~= "number" then
                return false, "value must be a number but was " .. type( value )
            end
            if opts.min and value < opts.min then
                return false, "value must be greater than or equal to " .. opts.min
            end

            if opts.max and value > opts.max then
                return false, "value must be less than or equal to " .. opts.max
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

return "Hello world"
