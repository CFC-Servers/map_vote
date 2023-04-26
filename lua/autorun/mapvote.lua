MapVote = {}
MapVote.Config = {}

MapVote.CurrentMaps = {}
MapVote.Votes = {}
MapVote.IsInProgress = false

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile( "mapvote/cl_mapvote.lua" )
    AddCSLuaFile( "mapvote/cl_mapvote_reopen_hint.lua" )
    AddCSLuaFile( "mapvote/client/vgui/map_icon.lua" )
    AddCSLuaFile( "mapvote/client/vgui/three_state_selector.lua" )

    local modulesFiles = file.Find( "mapvote/server/modules/*.lua", "LUA" )
    for _, filename in pairs( modulesFiles ) do
        include( "mapvote/server/modules/" .. filename )
    end

    local integrationsFiles = file.Find( "mapvote/server/integrations/*.lua", "LUA" )
    for _, filename in pairs( integrationsFiles ) do
        include( "mapvote/server/integrations/" .. filename )
    end

    -- client modules
    local modulesFiles = file.Find( "mapvote/client/modules/*.lua", "LUA" )
    for _, filename in pairs( modulesFiles ) do
        AddCSLuaFile( "mapvote/client/modules/" .. filename )
    end
else
    include( "mapvote/cl_mapvote.lua" )
    include( "mapvote/cl_mapvote_reopen_hint.lua" )
    include( "mapvote/client/vgui/map_icon.lua" )
    include( "mapvote/client/vgui/three_state_selector.lua" )

    local modulesFiles = file.Find( "mapvote/client/modules/*.lua", "LUA" )
    for _, filename in pairs( modulesFiles ) do
        include( "mapvote/client/modules/" .. filename )
    end
end

hook.Run( "MapVote_Loaded" )
