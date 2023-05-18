MapVote.Net = MapVote.Net or {}

util.AddNetworkString( "MapVote_RequestConfig" )
util.AddNetworkString( "MapVote_Config" )

util.AddNetworkString( "MapVote_RequestMapList" )
util.AddNetworkString( "MapVote_MapList" )

util.AddNetworkString( "MapVote_VoteStarted" )
util.AddNetworkString( "MapVote_VoteCancelled" )
util.AddNetworkString( "MapVote_VoteFinished" )

util.AddNetworkString( "MapVote_ChangeVote" )
util.AddNetworkString( "MapVote_PlayerChangedVote" )

util.AddNetworkString( "RTV_Delay" )

-- from client

MapVote.Net.receiveWithMiddleware( "MapVote_RequestConfig", function( _, ply )
    net.Start( "MapVote_Config" )
    net.WriteTable( MapVote.GetConfig() )
    net.Send( ply )
end, MapVote.Net.requirePermission( MapVote.PermCanConfigure ) )

MapVote.Net.receiveWithMiddleware( "MapVote_Config", function()
    local err = MapVote.SetConfig( net.ReadTable() )
    if err ~= nil then
        print( "MapVote: Config is invalid: " .. err )
        -- TODO return this to client
    end

    MapVote.SaveConfigToFile( MapVote.defaultConfigFilename )
end, MapVote.Net.requirePermission( MapVote.PermCanConfigure ) )

net.Receive( "MapVote_ChangeVote", function( _, ply )
    if not MapVote.state.isInProgress then return end
    if not IsValid( ply ) then return end

    local mapID = net.ReadUInt( 32 )
    if not MapVote.state.currentMaps[mapID] then return end

    MapVote.state.votes[ply:SteamID()] = mapID

    net.Start( "MapVote_PlayerChangedVote" )
    net.WriteEntity( ply )
    net.WriteUInt( mapID, 32 )
    net.Broadcast()
end )

MapVote.Net.receiveWithMiddleware( "MapVote_RequestMapList", function( _, ply )
    local maps = MapVote.getMapList()
    net.Start( "MapVote_MapList" )
    net.WriteUInt( #maps, 32 )
    for _, map in ipairs( maps ) do
        net.WriteString( map )
    end
    net.Send( ply )
end, MapVote.Net.requirePermission( MapVote.PermCanConfigure ) )

-- to client

function MapVote.Net.sendVoteStart( length, mapsInVote )
    net.Start( "MapVote_VoteStarted" )
    net.WriteUInt( #mapsInVote, 32 )
    for _, map in ipairs( mapsInVote ) do
        net.WriteString( map )
        net.WriteUInt( MapVote.PlayCounts[map] or 0, 32 )
    end
    net.WriteUInt( length, 32 )
    net.Broadcast()
end
