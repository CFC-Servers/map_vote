MapVote = {}
MapVote.Config = {}

MapVote.CurrentMaps = {}
MapVote.Votes = {}

MapVote.IsInProgress = false

MapVote.UPDATE_VOTE = 1
MapVote.UPDATE_WIN = 3

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile( "mapvote/cl_mapvote.lua" )
    AddCSLuaFile( "mapvote/cl_mapvote_reopen_hint.lua" )

    include( "mapvote/config.lua" )

    local files = file.Find( "mapvote/server/integrations/*.lua", "LUA" )
    for _, filename in pairs( files ) do
        include( "mapvote/server/integrations/" .. filename )
    end
    local files = file.Find( "mapvote/server/modules/*.lua", "LUA" )
    for _, filename in pairs( files ) do
        include( "mapvote/server/modules/" .. filename )
    end
else
    include( "mapvote/cl_mapvote.lua" )
    include( "mapvote/cl_mapvote_reopen_hint.lua" )
end