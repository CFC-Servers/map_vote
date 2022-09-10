MapVote = {}
MapVote.Config = {}

-- Default Config
MapVoteConfigDefault = {
    MapLimit = 24,
    TimeLimit = 28,
    AllowCurrentMap = false,
    EnableCooldown = true,
    MapsBeforeRevote = 3,
    RTVPlayerCount = 3,
    MapPrefixes = { "ttt_" },
    AutoGamemode = false,
    IncludedMaps = {}
}
-- Default Config

hook.Add( "Initialize", "MapVoteConfigSetup", function()
    if not file.Exists( "mapvote", "DATA" ) then file.CreateDir( "mapvote" ) end
    if not file.Exists( "mapvote/config.txt", "DATA" ) then
        file.Write( "mapvote/config.txt", util.TableToJSON( MapVoteConfigDefault ) )
    end
end )

MapVote.CurrentMaps = {}
MapVote.Votes = {}

MapVote.Allow = false

MapVote.UPDATE_VOTE = 1
MapVote.UPDATE_WIN = 3

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile( "mapvote/cl_mapvote.lua" )
    AddCSLuaFile( "mapvote/cl_mapvote_reopen_hint.lua" )

    include( "mapvote/config.lua" )
    include( "mapvote/sv_mapvote.lua" )
    include( "mapvote/rtv.lua" )

    local files = file.Find( "mapvote/integrations/*.lua", "LUA" )
    for _, fil in pairs( files ) do
        include( "mapvote/integrations/" .. fil )
    end
else
    include( "mapvote/cl_mapvote.lua" )
    include( "mapvote/cl_mapvote_reopen_hint.lua" )
end
