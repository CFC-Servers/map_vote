function MapVote.isMapAllowed( m )
    local conf = MapVote.config

    local hookResult = hook.Run( "MapVote_IsMapAllowed", m )
    if hookResult ~= nil then return hookResult end

    if not conf.AllowCurrentMap and m == game.GetMap():lower() then return false end -- dont allow current map in vote

    if conf.ExcludedMaps[m] then return false end -- dont allow excluded maps in vote
    if conf.IncludedMaps[m] then return true end -- skip prefix check if map is in included maps

    if conf.MapPrefixes then
        for _, v in pairs( conf.MapPrefixes ) do
            if string.find( m, "^" .. v ) then
                return true
            end
        end
    end

    if conf.UseGamemodeMapPrefixes and MapVote.gamemodeMapPrefixes then
        for _, v in pairs( MapVote.gamemodeMapPrefixes ) do
            if string.find( m, "^" .. v ) then
                return true
            end
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
    MapVote.state.endTime = CurTime() + length

    MapVote.Net.sendVoteStart( MapVote.state.endTime, mapsInVote )

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
    MapVote.RTV.ResetVotes()

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
