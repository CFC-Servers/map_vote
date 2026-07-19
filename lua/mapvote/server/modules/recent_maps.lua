function MapVote.wasMapRecentlyPlayed( map )
    local conf = MapVote.GetConfig()

    if MapVote.config.EnableCooldown ~= true then return end
    if not MapVote.recentMaps then
        MapVote.recentMaps = {}
        local recentMaps = MapVote.DB.GetRecentMaps( conf.MapsBeforeRevote or 3 )
        for _, v in pairs( recentMaps ) do
            MapVote.recentMaps[v.map] = true
        end
    end

    if MapVote.recentMaps[map] then return true end
end

---@param map string
---@return number minutes since the map was last played, math.huge if never played
function MapVote.MinutesSinceLastPlayed( map )
    local lastPlayed = MapVote.DB.GetLastPlayedTime( map )
    if not lastPlayed then return math.huge end

    return ( os.time() - lastPlayed ) / 60
end

hook.Add( "Initialize", "MapVote_UpdateDB", function()
    MapVote.DB.MapPlayed( game.GetMap() )

    local allMaps = MapVote.DB.GetAllMaps() or {}
    MapVote.PlayCounts = {}
    for _, v in pairs( allMaps ) do
        MapVote.PlayCounts[v.map] = tonumber( v.play_count )
    end
end )
