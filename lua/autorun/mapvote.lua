MapVote = {}
MapVote.Config = {}

MapVote.CurrentMaps = {}
MapVote.Votes = {}
MapVote.IsInProgress = false

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile( "mapvote/cl_mapvote.lua" )
    AddCSLuaFile( "mapvote/cl_mapvote_reopen_hint.lua" )
    AddCSLuaFile( "mapvote/client/thumb_downloader.lua" )

    local modulesFiles = file.Find( "mapvote/server/modules/*.lua", "LUA" )
    for _, filename in pairs( modulesFiles ) do
        include( "mapvote/server/modules/" .. filename )
    end

    local integrationsFiles = file.Find( "mapvote/server/integrations/*.lua", "LUA" )
    for _, filename in pairs( integrationsFiles ) do
        include( "mapvote/server/integrations/" .. filename )
    end
else
    include( "mapvote/cl_mapvote.lua" )
    include( "mapvote/cl_mapvote_reopen_hint.lua" )
    include( "mapvote/client/thumb_downloader.lua" )
end

hook.Run( "MapVote_Loaded" )

