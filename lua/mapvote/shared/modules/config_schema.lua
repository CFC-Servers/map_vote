require "schemavalidator"
local SV = SchemaValidator

local schema = SV.Object {
    MapLimit = SV.Int { min = 2 },
    TimeLimit = SV.Int { min = 1 },
    AllowCurrentMap = SV.Bool(),
    RTVPercentPlayersRequired = SV.Number { min = 0, max = 1 },
    RTVPercentMulWhenOverpopulated = SV.Number { min = 0, max = 1 },
    RTVWait = SV.Number(),
    VoteMultipliers = SV.Map( SV.String(), SV.Int { min = 0, max = 99 } ):Optional(),
    SortMaps = SV.Bool(),
    UseGamemodeMapPrefixes = SV.Bool():Optional(),
    MapPrefixes = SV.List( SV.String() ):Optional(),
    EnableCooldown = SV.Bool(),
    MapsBeforeRevote = SV.Int { min = 1 },
    RTVPlayerCount = SV.Int { min = 1 },
    ExcludedMaps = SV.Map( SV.String(), SV.Bool() ),
    IncludedMaps = SV.Map( SV.String(), SV.Bool() ),
    MapConfig = SV.Map( SV.String(), SV.Object( {
        MinPlayers = SV.Int { min = 0 }:Optional(),
        MaxPlayers = SV.Int { min = 0 }:Optional(),
    } ) ):Optional(),
    PlyRTVCooldownSeconds = SV.Int { min = 1 },
    MapIconURLs = SV.Map( SV.String(), SV.String() ):Optional(),

}

local default = {
    MapLimit = 24,
    TimeLimit = 28,
    RTVWait = 60,
    VoteMultipliers = {},
    AllowCurrentMap = false,
    EnableCooldown = true,
    MapsBeforeRevote = 3,
    RTVPlayerCount = 3,
    UseGamemodeMapPrefixes = true,
    MapPrefixes = {},
    IncludedMaps = {},
    ExcludedMaps = {},
    RTVPercentPlayersRequired = 0.66,
    RTVPercentMulWhenOverpopulated = 0.5,
    SortMaps = false,
    PlyRTVCooldownSeconds = 120,
    MapIconURLs = {},
    MapConfig = {},
}

MapVote.configSchema = schema
MapVote.configDefault = default
