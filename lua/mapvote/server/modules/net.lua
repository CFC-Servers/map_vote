util.AddNetworkString( "MapVote_VoteStarted" )
util.AddNetworkString( "MapVote_VoteCancelled" )
util.AddNetworkString( "MapVote_ChangeVote" )
util.AddNetworkString( "MapVote_VoteFinished" )
util.AddNetworkString( "MapVote_PlayerChangedVote" )
util.AddNetworkString( "MapVote_MapList" )
util.AddNetworkString( "RTV_Delay" )

-- from client
util.AddNetworkString( "MapVote_RequestMapList" )
util.AddNetworkString( "MapVote_RequestConfig" )

net.Receive( "MapVote_RequestMapList", function( _, ply )
    if not ply:IsSuperAdmin() then return end

    local mapList = MapVote.getMapList()

    net.Start( "MapVote_MapList" )
    net.WriteUInt( #mapList, 32 )
    for _, map in pairs( mapList ) do
        net.WriteString( map )
    end
    net.Send( ply )
end )

net.Receive( "MapVote_RequestConfig", function( _, ply )
    if not ply:IsSuperAdmin() then return end

    net.Start( "MapVote_Config" )
    net.WriteTable( MapVote.GetConfig() )
    net.Send( ply )
end )

net.Receive( "MapVote_Config", function( _, ply )
    if not ply:IsSuperAdmin() then return end
    local err = MapVote.SetConfig( net.ReadTable() )
    if err ~= nil then
        print( "MapVote: Config is invalid: " .. err )
        -- TODO return this to client
    end

    MapVote.SaveConfigToFile( MapVote.defaultConfigFilename )
end )
-- to client
util.AddNetworkString( "MapVote_Config" )
util.AddNetworkString( "MapVote_MapListe" )
