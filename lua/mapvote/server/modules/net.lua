MapVote.Net = MapVote.Net or {}

util.AddNetworkString( "MapVote_RequestConfig" )
util.AddNetworkString( "MapVote_Config" )

util.AddNetworkString( "MapVote_RequestMapList" )
util.AddNetworkString( "MapVote_MapList" )

util.AddNetworkString( "MapVote_VoteStarted" )
util.AddNetworkString( "MapVote_VoteCancelled" )
util.AddNetworkString( "MapVote_VoteFinished" )

util.AddNetworkString( "MapVote_RequestVoteState" )

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

MapVote.Net.receiveWithMiddleware( "MapVote_ChangeVote", function( _, ply )
    if not MapVote.state.isInProgress then return end
    if not IsValid( ply ) then return end

    local mapID = net.ReadUInt( 32 )
    if not MapVote.state.currentMaps[mapID] then
        print( "MapVote: Player " .. ply:Nick() .. " tried to vote for invalid map " .. mapID )
        return
    end

    MapVote.state.votes[ply:SteamID()] = mapID

    net.Start( "MapVote_PlayerChangedVote" )
    net.WriteEntity( ply )
    net.WriteUInt( mapID, 32 )
    net.Broadcast()
end, MapVote.Net.rateLimit( "MapVote_ChangeVote", 15, 3 ) )

MapVote.Net.receiveWithMiddleware( "MapVote_RequestMapList", function( _, ply )
    local maps = MapVote.getMapList()
    net.Start( "MapVote_MapList" )
    net.WriteUInt( #maps, 32 )
    for _, map in ipairs( maps ) do
        net.WriteString( map )
    end
    net.Send( ply )
end, MapVote.Net.requirePermission( MapVote.PermCanConfigure ) )

MapVote.Net.receiveWithMiddleware( "MapVote_RequestVoteState", function( _, ply )
    if not MapVote.state.isInProgress then return end
    MapVote.Net.sendVoteStart( MapVote.state.endTime, MapVote.state.currentMaps, ply )
    timer.Simple( 0.1, function()
        for steamID, mapID in pairs( MapVote.state.votes ) do
            net.Start( "MapVote_PlayerChangedVote" )
            net.WriteEntity( player.GetBySteamID( steamID ) )
            net.WriteUInt( mapID, 32 )
            net.Send( ply )
        end
    end )
end, MapVote.Net.rateLimit( "MapVote_RequestVoteState", 2, 0.1 ) )

MapVote.Net.receiveWithMiddleware( "MapVote_RequestWorkshopIDTable", function( _, ply )
    local requestedMaps = net.ReadTable()
    local addonWorkshopIDs = MapVote.getWorkshopIDs( requestedMaps )
    net.Start( "MapVote_WorkshopIDTable" )
    net.WriteTable( addonWorkshopIDs )
    net.Send( ply )
end, MapVote.Net.rateLimit( "MapVote_RequestWorkshopIDTable", 5, 0.5 ) )

-- to client

function MapVote.Net.sendVoteStart( endTime, mapsInVote, ply )
    net.Start( "MapVote_VoteStarted" )
    net.WriteUInt( #mapsInVote, 32 )
    for _, map in ipairs( mapsInVote ) do
        net.WriteString( map )
        net.WriteUInt( MapVote.PlayCounts[map] or 0, 32 )
        net.WriteString( MapVote.GetConfig().MapIconURLs[map] or "" )
    end
    net.WriteUInt( endTime, 32 )
    if not ply then
        net.Broadcast()
    else
        net.Send( ply )
    end
end
