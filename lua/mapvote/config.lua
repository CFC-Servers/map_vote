-- TODO rewrite entire config system to allow easilly sending values to clients and adding new config options
if file.Exists( "mapvote/config.txt", "DATA" ) then
    MapVote.Config = util.JSONToTable( file.Read( "mapvote/config.txt", "DATA" ) )
else
    MapVote.Config = {}
end

MapVote.Config.IncludedMaps = MapVote.Config.IncludedMaps or {}
MapVote.Config.ExcludedMaps = MapVote.Config.ExcludedMaps or {}

 -- Normalise config values and populate empty values
 MapVote.Config.MapLimit = MapVote.Config.MapLimit or 24

if MapVote.Config.MapPrefixes and type( MapVote.Config.MapPrefixes ) == "string" then
    MapVote.Config.MapPrefixes = { MapVote.Config.MapPrefixes }
end

if MapVote.Config.MapPrefixes == nil then -- load map prefix from gamemode txt file
    local info = file.Read( GAMEMODE.Folder .. "/" .. GAMEMODE.FolderName .. ".txt", "GAME" )

    if info then
        local decoded = util.KeyValuesToTable( info )
        prefix = info.maps
        if decoded.maps then
            if decoded.maps[0] == "^" then
                MapVote.Config.MapPrefixes = { string.sub(decoded.maps, 2) }
            else
                MapVote.Config.MapPrefixes = { decoded.maps }
            end
        end
    else
        ErrorNoHalt( "MapVote Prefix can not be loaded from gamemode" )
    end

end