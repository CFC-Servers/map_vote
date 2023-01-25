-- Default Config
local MapVoteConfigDefault = {
    MapLimit = 24,
    TimeLimit = 28,
    RTVWait = 60,
    AllowCurrentMap = false,
    EnableCooldown = true,
    MapsBeforeRevote = 3,
    RTVPlayerCount = 3,
    IncludedMaps = {},
    ExcludedMaps = {},
    MinimumPlayersBeforeReset = -1,
    TimeToReset = 5 * 60,
    DefaultMap = "gm_construct",
    PercentPlayersRequired = 0.66,
    RTVPlayerCount = 3
}
if not file.Exists( "mapvote", "DATA" ) then file.CreateDir( "mapvote" ) end

if file.Exists( "mapvote/config.txt", "DATA" ) then
    MapVote.Config = util.JSONToTable( file.Read( "mapvote/config.txt", "DATA" ) )
else
    MapVote.Config = MapVoteConfigDefault
    file.Write( "mapvote/config.txt", util.TableToJSON( MapVoteConfigDefault ) )
end

for k, _ in pairs(MapVoteConfigDefault) do
    if MapVote.Config[k] == nil then
        MapVote.Config[k] = MapVoteConfigDefault[k]
    end
end

if MapVote.Config.MapPrefixes == nil then -- load map prefix from gamemode txt file
    local info = file.Read( GAMEMODE.Folder .. "/" .. GAMEMODE.FolderName .. ".txt", "GAME" )

    if info then
        local decoded = util.KeyValuesToTable( info )
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

hook.Run("MapVote_ConfigLoaded")