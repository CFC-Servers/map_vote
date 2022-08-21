-- TODO rewrite entire config system to allow easilly sending values to clients and adding new config options
if file.Exists("mapvote/config.txt", "DATA") then
    MapVote.Config = util.JSONToTable(file.Read("mapvote/config.txt", "DATA"))
else
    MapVote.Config = {}
end

MapVote.Config.IncludedMaps = MapVote.Config.IncludedMaps or {}
MapVote.Config.ExcludedMaps = MapVote.Config.ExcludedMaps or {}