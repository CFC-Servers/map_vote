MapVote.defaultConfigFilename = "mapvote/config.json"

function MapVote.GetConfig()
    return MapVote.config
end

function MapVote.MergeConfig( conf )
    for k, v in pairs( conf ) do
        local valid, reason = MapVote.configSchema:ValidateField( k, v )
        if not valid then
            MapVote.configIssues = {}
            print( "MapVote MergeConfig config is invalid: " .. reason )
            return reason
        end
        MapVote.config[k] = v
    end
end

function MapVote.SetConfig( conf )
    local valid, reason = MapVote.configSchema:Validate( conf )
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

---@return boolean @Did an old config get migrated to default config path
function MapVote.MigrateOldConfigs()
    if file.Exists( "mapvote/config.txt", "DATA" ) and not file.Exists( MapVote.defaultConfigFilename, "DATA" ) then -- original config
        file.Rename( "mapvote/config.txt", MapVote.defaultConfigFilename )
        return true
    end
    return false
end

function MapVote.LoadConfig()
    -- Default Config
    local defaultConfigErr = MapVote.SetConfig( MapVote.configDefault )
    if defaultConfigErr then
        error( "MapVote default config is invalid: " .. defaultConfigErr )
    end

    if file.Exists( MapVote.defaultConfigFilename, "DATA" ) then
        local err = MapVote.LoadConfigFromFile( MapVote.defaultConfigFilename )
        if err then
            print( "MapVote config is invalid: " .. err )
        end
    else
        if MapVote.MigrateOldConfigs() then
            return MapVote.LoadConfig()
        end
        MapVote.SaveConfigToFile( MapVote.defaultConfigFilename )
    end

    print( "MapVote config loaded" )
end

if not file.Exists( "mapvote", "DATA" ) then file.CreateDir( "mapvote" ) end

MapVote.LoadConfig()
