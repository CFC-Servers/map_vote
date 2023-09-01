require "schemavalidator"
local SV = SchemaValidator

local schema = SV.Object {
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
    TimeToReset = SV.Int { min = 1 }
}

local default = {
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
    PlyRTVCooldownSeconds = 120,
}

MapVote.configSchema = schema
MapVote.configDefault = default
