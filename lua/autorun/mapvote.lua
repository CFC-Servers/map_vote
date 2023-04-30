MapVote = {}
MapVote.config = {}

local function runOnDir( dir, action )
    local files = file.Find( dir .. "/*.lua", "LUA" )
    for _, filename in pairs( files ) do
        action( dir .. "/" .. filename )
    end
end

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile( "mapvote/cl_mapvote.lua" )
    AddCSLuaFile( "mapvote/cl_mapvote_reopen_hint.lua" )
    AddCSLuaFile( "includes/modules/schemavalidator.lua" )

    runOnDir( "mapvote/shared/modules", function( f )
        AddCSLuaFile( f )
        include( f )
    end )

    runOnDir( "mapvote/server/modules/", include )
    runOnDir( "mapvote/server/integrations/", include )

    runOnDir( "mapvote/client/modules", AddCSLuaFile )
    runOnDir( "mapvote/client/vgui", AddCSLuaFile )
else
    include( "mapvote/cl_mapvote.lua" )
    include( "mapvote/cl_mapvote_reopen_hint.lua" )

    runOnDir( "mapvote/shared/modules", include )
    runOnDir( "mapvote/client/modules", include )
    runOnDir( "mapvote/client/vgui", include )
end

hook.Run( "MapVote_Loaded" )
