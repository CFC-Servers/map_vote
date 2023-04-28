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
MapVote.schema = schema
