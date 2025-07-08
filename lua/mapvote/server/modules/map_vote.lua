function MapVote.isMapAllowed( m )
    local conf = MapVote.config

    local hookResult = hook.Run( "MapVote_IsMapAllowed", m )
    if hookResult ~= nil then return hookResult end

    if MapVote.wasMapRecentlyPlayed( m ) then return false end -- dont allow recently played maps in vote
    if not conf.AllowCurrentMap and m == game.GetMap():lower() then return false end -- dont allow current map in vote

    if conf.MapConfig and conf.MapConfig[m] then
        local cfg = conf.MapConfig[m]
        if cfg.MinPlayers and player.GetCount() < cfg.MinPlayers then return false end
        if cfg.MaxPlayers and cfg.MaxPlayers ~= 0 and player.GetCount() > cfg.MaxPlayers then return false end
    end

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

    local mapsInVote = hook.Run( "MapVote_SelectMaps" )
    if not mapsInVote then
        mapsInVote = {}
        for _, map in RandomPairs( maps ) do
            if MapVote.isMapAllowed( map ) then
                table.insert( mapsInVote, map )

                if #mapsInVote >= MapVote.config.MapLimit then break end
            end
        end
    end

    if #mapsInVote == 0 then
        ErrorNoHalt( "Voted aborted, there were zero maps in the vote" )
        return
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

function MapVote.GetVoteMultiplier( ply )
    local multiplier = MapVote.config.VoteMultipliers[ply:GetUserGroup()] or 1

    local hookMult = hook.Run( "MapVote_VoteMultiplier", ply )

    if isnumber( hookMult ) then
        multiplier = hookMult
    end

    return multiplier
end

function MapVote.mapVoteOver( delay )
    delay = delay or 4

    -- copy final votes to prevent votes changing during delay
    local state = MapVote.state
    MapVote.resetState()
    MapVote.state.isInProgress = true

    -- If this function errors we still want isInProgress set to false
    timer.Simple( delay + 1, function()
        MapVote.resetState()
    end )

    local results = {}

    for k, v in pairs( state.votes ) do
        if not results[v] then results[v] = 0 end

        local ply = player.GetBySteamID( k )

        if ply then
            local voteMult = MapVote.GetVoteMultiplier( ply )
            results[v] = results[v] + voteMult
        else
            print( "Discarding vote from invalid player: " .. k )
        end
    end

    for k, v in pairs( results ) do
        print( "MapVote: Map " .. state.currentMaps[k] .. " received " .. v .. " votes." )
    end

    local winner = MapVote.GetWinningKey( results ) or 1
    hook.Run( "MapVote_VoteFinished", {
        state = state,
        results = results,
        winner = winner
    } )

    net.Start( "MapVote_VoteFinished" )
    net.WriteUInt( winner, 32 )
    net.Broadcast()
    local map = state.currentMaps[winner]

    timer.Simple( delay, function()
        if hook.Run( "MapVote_ChangeMap", map ) == false then return end

        print( "MapVote Changing map to: " .. map )
        RunConsoleCommand( "changelevel", map )
    end )
end

---@param tab table
---@return any
function MapVote.GetWinningKey( tab )
    local highest = -math.huge
    local count = 0

    for _, v in pairs( tab ) do
        if v > highest then
            highest = v
            count = 1
        elseif v == highest then
            count = count + 1
        end
    end

    local desired = math.random( 1, count )
    local i = 0
    for k, v in pairs( tab ) do
        if v == highest then
            i = i + 1
        end
        if i == desired then
            return k
        end
    end

    return nil
end
