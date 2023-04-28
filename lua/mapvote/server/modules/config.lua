function MapVote.GetConfig()
    return MapVote.config
end

function MapVote.MergeConfig( conf )
    for k, v in pairs( conf ) do
        local valid, reason = MapVote.schema:ValidateField( k, v )
        if not valid then
            MapVote.configIssues = {}
            print( "MapVote MergeConfig config is invalid: " .. reason )
            return reason
        end
        MapVote.config[k] = v
    end
end

function MapVote.SetConfig( conf )
    local valid, reason = MapVote.schema:Validate( conf )
    if not valid then
        print( "MapVote SetConfig config is invalid: " .. reason )
        return reason
    end
    MapVote.config = conf
    return nil
end

function MapVote.LoadConfigFromFile( filename )
    local fileData = file.Read( filename, "DATA" )
    if not fileData then
        print( "MapVote config is invalid: " .. filename .. " does not exist" )
        return
    end
    local cfg = util.JSONToTable( fileData )
    if not cfg then
        print( "MapVote config is invalid: " .. filename .. " is not a valid JSON file" )
        return
    end
    return MapVote.MergeConfig( cfg )
end

function MapVote.SaveConfigToFile( filename )
    file.Write( filename, util.TableToJSON( MapVote.GetConfig(), true ) )
end

MapVote.DefaultFilename = "mapvote/config.json"

-- Default Config
local defaultConfigErr = MapVote.SetConfig {
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
    RTVPercentPlayersRequired = 0.66,
    SortMaps = false,
}

if defaultConfigErr then
    error( "MapVote default config is invalid: " .. defaultConfigErr )
end

if not file.Exists( "mapvote", "DATA" ) then file.CreateDir( "mapvote" ) end

if file.Exists( MapVote.DefaultFilename, "DATA" ) then
    local err = MapVote.LoadConfigFromFile( MapVote.DefaultFilename )
    if err then
        print( "MapVote config is invalid: " .. err )
    end
else
    MapVote.SaveConfigToFile( MapVote.DefaultFilename )
end

print( "MapVote config loaded" )
hook.Run( "MapVote_ConfigLoaded" )
