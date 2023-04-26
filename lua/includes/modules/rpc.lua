-- a dead simple RPC library

require "schemavalidator"
local SV = SchemaValidator

RPC = {
    _functions = {},
    _callbacks = {},
    _current_nonce = 0
}
util.AddNetworkString( "RPC_Response" )

---@param ply Player
net.Receive( "RPC_Response", function( _, ply )
    local nonce = net.ReadUInt( 32 )
    local ok = net.ReadBool()
    local data = net.ReadTable()

    local callback = RPC._callbacks[nonce]
    if not callback then return end
    if callback.ply ~= ply then
        -- this should only happen if someone is exploiting
        print( "RPC: Got response from wrong player: ", nonce, ply:SteamID() )
        return
    end
    RPC._callbacks[nonce] = nil
    callback.func( ok, data )
end )

---@param name string
---@param dataType SchemaType
---@param func fun( ply: Player, data: any )
function RPC.Define( name, dataType, func )
    local entry = {
        name = name,
        func = func,
        dataType = dataType,
        netName = "RPC_" .. name
    }
    RPC._functions[name] = entry

    util.AddNetworkString( entry.netName )

    net.Receive( RPC[name].netName, function( _, ply )
        local nonce = net.ReadUInt( 32 )
        local data = net.ReadTable()

        local ok, err = entry.dataType:Validate( data )
        if not ok then
            net.Start( entry.netName )
            net.WriteUint( nonce, 32 )
            net.WriteBool( false )
            net.WriteString( err )
            if SERVER then
                net.Send( ply )
            else
                net.SendToServer()
            end
        end

        local resp = entry.func( ply, data )
        if resp ~= nil then
            net.Start( "RPC_Response" )
            net.WriteUint( nonce, 32 )
            net.WriteBool( true )
            net.WriteTable( resp )
            if SERVER then
                net.Send( ply )
            else
                net.SendToServer()
            end
        end
    end )
end

function RPC.Call( ply, name, data, callback )
    net.Start( "RPC_" .. name )
    net.WriteTable( data )
    if SERVER then
        net.Send( ply )
    else
        net.SendToServer()
    end

    if callback then
        RPC._callbacks[RPC._current_nonce] = {
            ply = ply,
            func = callback,
        }
        RPC._current_nonce = RPC._current_nonce + 1
    end
end

RPC.Define( "GetMaps", {}, function()

end )
