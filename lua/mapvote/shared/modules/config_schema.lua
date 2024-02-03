require "schemavalidator"
local SV = SchemaValidator

local schema = SV.Object {
    MapLimit = SV.Int { min = 2 },
    TimeLimit = SV.Int { min = 1 },
    AllowCurrentMap = SV.Bool(),
    RTVPercentPlayersRequired = SV.Number { min = 0, max = 1 },
    RTVWait = SV.Number(),
    SortMaps = SV.Bool(),
    UseGamemodeMapPrefixes = SV.Bool():Optional(),
    MapPrefixes = SV.List( SV.String() ):Optional(),
    EnableCooldown = SV.Bool(),
    MapsBeforeRevote = SV.Int { min = 1 },
    RTVPlayerCount = SV.Int { min = 1 },
    ExcludedMaps = SV.Map( SV.String(), SV.Bool() ),
    IncludedMaps = SV.Map( SV.String(), SV.Bool() ),
    PlyRTVCooldownSeconds = SV.Int { min = 1 },
    MapIconURLs = SV.Map( SV.String(), SV.String() ):Optional(),
}

local default = {
    MapLimit = 24,
    TimeLimit = 28,
    RTVWait = 60,
    AllowCurrentMap = false,
    EnableCooldown = true,
    MapsBeforeRevote = 3,
    RTVPlayerCount = 3,
    UseGamemodeMapPrefixes = true,
    MapPrefixes = {},
    IncludedMaps = {},
    ExcludedMaps = {},
    RTVPercentPlayersRequired = 0.66,
    SortMaps = false,
    PlyRTVCooldownSeconds = 120,
    MapIconURLs = {},
}

MapVote.configSchema = schema
MapVote.configDefault = default
