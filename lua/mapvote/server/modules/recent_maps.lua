hook.Add( "MapVote_IsMapAllowed", "MapVote_CheckRecentMaps", function( map )
    if MapVote.Config.EnableCooldown ~= true then return end
    if not MapVote.recentMaps then
        MapVote.recentMaps = {}
        local recentMaps = MapVote.DB.GetRecentMaps( MapVote.Config.MapsBeforeRevote or 3 )
        for _, v in pairs( recentMaps ) do
            MapVote.recentMaps[v.map] = true
        end
    end

    if MapVote.recentMaps[map] then return false end
end)

hook.Add( "Initialize", "MapVote_UpdateDB", function()
    MapVote.DB.MapPlayed( game.GetMap() )

    local allMaps = MapVote.DB.GetAllMaps() or {}
    MapVote.PlayCounts = {}
    for _, v in pairs( allMaps ) do
        MapVote.PlayCounts[v.map] = tonumber( v.play_count )
    end
end)