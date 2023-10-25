require "schemavalidator"
local SV = SchemaValidator

local schemaV1 = SV.Object {
    Version = SV.String():Metadata({ internal = true }),

    MapLimit = SV.Int { min = 2 }:Metadata{ 
        description = "the map limit for a single vote panel" 
    },
    Duration = SV.Int { min = 1 }:Metadata{
        description = "the default time a vote lasts"
    },
    AllowCurrentMap = SV.Bool():Metadata{
        description = "should the current map be allowed to appaer on the vote"
    },
    RTVPercentPlayersRequired = SV.Number { min = 0, max = 1 }:Metadata{
        description = "the percentage of players required to rtv"
    },
    RTVMinimumMapPlaytime = SV.Number():Metadata{
        description = "the minimum amount of time a map must be played before an RTV can be called"
    },
    MapCooldown = SV.Bool():Metadata{
        description = "should maps be put on cooldown after being played"
    },
    MapsBeforeRevote = SV.Int { min = 1 }:Metadata{
        description = "the number of maps that must be played before a map can be revoted"
    },
    SortMaps = SV.Bool():Metadata{
        description = "should the maps be sorted alphabetically"
    },
    MapPrefixes = SV.List( SV.String() ):Optional():Metadata{
        description = "maps with these prefixes will be enabled by default, if this is not specified map prefixes will be used from the active gamemode"
    },
    RTVMinimumPlayerCount = SV.Int { min = 1 }:Metadata{
        description = "the minimum number of players required to allow RTV voting"
    },
    PlyRTVCooldownSeconds = SV.Int { min = 1 }:Metadata{
        description = "the number of seconds a player must wait before voting for an RTV again"
    },

    ExcludedMaps = SV.Map( SV.String(), SV.Bool() ),
    IncludedMaps = SV.Map( SV.String(), SV.Bool() ),
    MapIconURLs = SV.Map( SV.String(), SV.String() ):Optional(),

    DefaultMap = SV.String():Metadata({internal=true}), -- deprecated
    MinimumPlayersBeforeReset = SV.Int {}:Metadata({internal=true}), -- deprecated
    TimeToReset = SV.Int { min = 1 }:Metadata({internal=true}), -- depreacted

}


---@param obj table
local function v0Migrator(obj)
    if obj.version ~= nil then return end

    obj.Version = "v1"
    obj.Duration = obj.TimeLimit
    obj.MapCooldown = obj.EnableCooldown
    obj.RTVMinimumMapPlaytime = obj.RTVWait
    obj.RTVMinimumPlayerCount = obj.RTVPlayerCount
    -- obj.MapConfig = {}
    -- for map, v in pairs(obj.IncludedMaps) do
    --     if v then obj.MapConfig[map] = { Allowed = true } end
    -- end
    -- for map, v in pairs(obj.ExcludedMaps) do
    --     if v then obj.MapConfig[map] = { Allowed = false } end
    -- end
    -- for map, url in pairs(obj.MapIconURLs) do
    --     obj.MapConfig[map] = obj.MapConfig[map] or {}
    --     obj.MapConfig[map].IconURL = url
    -- end
    return obj
end

local schemaV0 = SV.Object {
    MapLimit = SV.Int { min = 2 },
    TimeLimit = SV.Int { min = 1 },
    AllowCurrentMap = SV.Bool(),
    RTVPercentPlayersRequired = SV.Number { min = 0, max = 1 },
    RTVWait = SV.Number(),
    SortMaps = SV.Bool(),
    DefaultMap = SV.String(),
    MapPrefixes = SV.List( SV.String() ):Optional(),
    EnableCooldown = SV.Bool(),
    MapsBeforeRevote = SV.Int { min = 1 },
    RTVPlayerCount = SV.Int { min = 1 },
    ExcludedMaps = SV.Map( SV.String(), SV.Bool() ),
    IncludedMaps = SV.Map( SV.String(), SV.Bool() ),
    MinimumPlayersBeforeReset = SV.Int {},
    TimeToReset = SV.Int { min = 1 },
    PlyRTVCooldownSeconds = SV.Int { min = 1 },
    MapIconURLs = SV.Map( SV.String(), SV.String() ):Optional(),
}

local default = {
    Version = "v1",
    MapLimit = 24,
    Duration = 28,
    RTVMinimumMapPlaytime = 60,
    AllowCurrentMap = false,
    MapCooldown = true,
    MapsBeforeRevote = 3,
    RTVMinimumPlayerCount = 3,
    MapConfig = {},
    MinimumPlayersBeforeReset = -1,
    TimeToReset = 5 * 60,
    DefaultMap = "gm_construct",
    RTVPercentPlayersRequired = 0.66,
    SortMaps = false,
    PlyRTVCooldownSeconds = 120,
    MapIconURLs = {},
}

MapVote.configSchema = schemaV1

---@type (fun(obj: table): table|nil)[]
MapVote.migrators = { v0Migrator }
MapVote.configDefault = default
