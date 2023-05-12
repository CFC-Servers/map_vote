util.AddNetworkString( "MapVote_VoteStarted" )
util.AddNetworkString( "MapVote_VoteCancelled" )
util.AddNetworkString( "MapVote_ChangeVote" )
util.AddNetworkString( "MapVote_VoteFinished" )
util.AddNetworkString( "MapVote_PlayerChangedVote" )
util.AddNetworkString( "MapVote_RequestMapList" )
util.AddNetworkString( "MapVote_MapList" )
util.AddNetworkString( "RTV_Delay" )

function MapVote.sendToClient( length, mapsInVote )
    net.Start( "MapVote_VoteStarted" )
    net.WriteUInt( #mapsInVote, 32 )
    for _, map in ipairs( mapsInVote ) do
        net.WriteString( map )
        net.WriteUInt( MapVote.PlayCounts[map] or 0, 32 )
    end
    net.WriteUInt( length, 32 )
    net.Broadcast()
end

function MapVote.isMapAllowed( m )
    local conf = MapVote.config
    local prefixes = conf.MapPrefixes or MapVote.gamemodeMapPrefixes or {}
    local hookResult = hook.Run( "MapVote_IsMapAllowed", m )
    if hookResult ~= nil then return hookResult end

    if not conf.AllowCurrentMap and m == game.GetMap():lower() then return false end -- dont allow current map in vote

    if conf.ExcludedMaps[m] then return false end -- dont allow excluded maps in vote
    if conf.IncludedMaps[m] then return true end -- skip prefix check if map is in included maps

    for _, v in pairs( prefixes ) do
        if string.find( m, "^" .. v ) then
            return true
        end
    end
    return false
end

MapVote._maps = nil
function MapVote.getMapList()
    if MapVote._maps then return MapVote._maps end

    local maps = file.Find( "maps/*.bsp", "GAME" )
    for i, v in ipairs( maps ) do
        maps[i] = v:sub( 1, -5 ) -- strip .bsp
    end

    MapVote._maps = maps
    return maps
end

net.Receive( "MapVote_RequestMapList", function( _, ply )
    if not ply:IsAdmin() then return end

    local maps = MapVote.getMapList()
    net.Start( "MapVote_MapList" )
    net.WriteUInt( #maps, 32 )
    for _, map in ipairs( maps ) do
        net.WriteString( map )
    end
    net.Send( ply )
end )

function MapVote.Start( length )
    length = length or MapVote.config.TimeLimit or 30

    local maps = MapVote.getMapList()

    local mapsInVote = {}

    for _, map in RandomPairs( maps ) do
        if MapVote.isMapAllowed( map ) then
            table.insert( mapsInVote, map )

            if #mapsInVote >= MapVote.config.MapLimit then break end
        end
    end

    if MapVote.config.SortMaps then table.sort( mapsInVote ) end

    MapVote.state.isInProgress = true
    MapVote.state.currentMaps = mapsInVote
    MapVote.state.votes = {}

    MapVote.sendToClient( length, mapsInVote )

    timer.Create( "MapVote_EndVote", length, 1, MapVote.mapVoteOver )
end

function MapVote.resetState()
    MapVote.state = {
        isInProgress = false,
        currentMaps = {},
        votes = {}
    }
end

MapVote.resetState()

function MapVote.Cancel()
    if not MapVote.state.isInProgress then return end

    MapVote.resetState()


    net.Start( "MapVote_VoteCancelled" )
    net.Broadcast()

    timer.Remove( "MapVote_EndVote" )
end

function MapVote.mapVoteOver()
    local state = MapVote.state
    MapVote.resetState()
    local results = {}

    for k, v in pairs( state.votes ) do
        if not results[v] then results[v] = 0 end

        if player.GetBySteamID( k ) then
            results[v] = results[v] + 1
        end
    end

    local winner = table.GetWinningKey( results ) or 1
    hook.Run( "MapVote_VoteFinished", {
        state = state,
        results = results,
        winner = winner
    } )

    net.Start( "MapVote_VoteFinished" )
    net.WriteUInt( winner, 32 )
    net.Broadcast()
    local map = state.currentMaps[winner]

    timer.Simple( 4, function()
        if hook.Run( "MapVote_ChangeMap", map ) == false then return end

        print( "MapVote Changing map to " .. map )
        RunConsoleCommand( "changelevel", map )
    end )
end

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
