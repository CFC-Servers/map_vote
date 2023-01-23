util.AddNetworkString( "MapVote_VoteStarted" )
util.AddNetworkString( "MapVote_VoteCancelled" )
util.AddNetworkString( "RTV_Delay" )
util.AddNetworkString( "MapVote_ChangeVote")
util.AddNetworkString( "MapVote_VoteFinished" )
util.AddNetworkString( "MapVote_PlayerChangedVote")

function MapVote.sendToClient(length, mapsInVote)
    net.Start( "MapVote_VoteStarted" )
        net.WriteUInt( #mapsInVote, 32 )
        for _, map in ipairs(mapsInVote) do
            net.WriteString( map )
            net.WriteUInt( MapVote.PlayCounts[map] or 0, 32 ) -- need this for backwards compatibility
        end

        net.WriteUInt( length, 32 )
    net.Broadcast()
end

function MapVote.isMapAllowed( m ) -- TODO rewrite
    local conf = MapVote.Config
    local prefixes = conf.MapPrefixes
    if prefixes and type( prefixes ) == "string" then -- This should be done at configuration step
        prefixes = { prefixes }
    end

    local hookResult = hook.Run( "MapVote_IsMapAllowed", m)
    if hookResult ~= nil then return hookResult end

    if not MapVote.AllowCurrentMap and m == game.GetMap():lower() .. ".bsp" then return false end -- dont allow current map in vote
    if MapVote.Config.ExcludedMaps[m] then return false end -- dont allow excluded maps in vote

    if MapVote.Config.IncludedMaps[m] then return true end -- skip prefix check if map is in included maps

    for _, v in pairs( prefixes ) do
        if string.find( m, "^" .. v ) then
            return true
        end
    end
    return false
end

function MapVote.Start( length )
    length = length or MapVote.Config.TimeLimit or 30

    local maps = file.Find( "maps/*.bsp", "GAME" )

    local mapsInVote = {}

    for _, map in RandomPairs( maps ) do
        map = map:sub( 1, -5 ) -- strip .bsp
        if MapVote.isMapAllowed( map ) then
            table.insert( mapsInVote, map )

            if #mapsInVote >= MapVote.Config.MapLimit then break end
        end
    end

    MapVote.State.IsInProgress = true
    MapVote.State.CurrentMaps = mapsInVote
    MapVote.State.Votes = {}

    MapVote.sendToClient(length, MapVote.State.CurrentMaps)

    timer.Create( "MapVote_EndVote", length, 1, function()
        MapVote.mapVoteOver()
    end )
end

function MapVote.resetState()
    MapVote.State = {
        IsInProgress = false,
        CurrentMaps = {},
        Votes = {}
    }
end
MapVote.resetState()

function MapVote.Cancel()
    if not MapVote.State.IsInProgress then return end

    MapVote.resetState()

    net.Start( "MapVote_VoteCancelled" )
    net.Broadcast()

    timer.Remove( "MapVote_EndVote" )
end

function MapVote.mapVoteOver( )
    local state = MapVote.State
    MapVote.resetState()
    local results = {}

    for k, v in pairs( state.Votes ) do
        if not results[v] then results[v] = 0 end

        if player.GetBySteamID( k ) then
            results[v] = results[v] + 1
        end
    end

    local winner = table.GetWinningKey( results ) or 1
    
    hook.Run("MapVote_VoteFinished", {
        state = state,
        results = results,
        winner= winner
    })


    net.Start( "MapVote_VoteFinished" )
        net.WriteUInt( winner, 32 )
    net.Broadcast()
    local map = state.CurrentMaps[winner]

    timer.Simple( 4, function()
        if hook.Run( "MapVoteChange", map ) == false then return end

        print( "MapVote Changing map to " .. map )
        RunConsoleCommand( "changelevel", map )
    end )
end

net.Receive( "MapVote_ChangeVote", function(  _, ply )
    if not MapVote.State.IsInProgress then return end
    if not IsValid( ply ) then return end

    local mapID = net.ReadUInt( 32 )
    if not MapVote.State.CurrentMaps[mapID] then return end

    MapVote.State.Votes[ply:SteamID()] = mapID

    net.Start( "MapVote_PlayerChangedVote" )
        net.WriteEntity( ply )
        net.WriteUInt( mapID, 32 )
    net.Broadcast()
end )
