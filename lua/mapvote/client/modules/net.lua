MapVote.Net = MapVote.Net or {}

-- receivers
net.Receive( "MapVote_MapList", function()
    local mapList = {}
    local mapCount = net.ReadUInt( 32 )
    for i = 1, mapCount do
        mapList[i] = net.ReadString()
    end

    MapVote.fullMapList = mapList
    hook.Run( "MapVote_MapListRecieved", mapList )
end )

net.Receive( "MapVote_Config", function()
    local config = net.ReadTable()
    MapVote.config = config
    hook.Run( "MapVote_ConfigRecieved", config )
end )

-- senders
local tempID = 0
function MapVote.Net.SendMapListRequest( cb )
    net.Start( "MapVote_RequestMapList" )
    net.SendToServer()

    tempID = tempID + 1
    local hookID = tempID
    hook.Add( "MapVote_MapListRecieved", "Temp_" .. hookID, function( mapList )
        hook.Remove( "MapVote_MapListRecieved", "Temp_" .. hookID )
        if cb then
            cb( mapList )
        end
    end )
end

function MapVote.Net.SendConfig()
    net.Start( "MapVote_Config" )
    net.WriteTable( MapVote.config )
    net.SendToServer()
end

function MapVote.Net.SendConfigRequest( cb )
    net.Start( "MapVote_RequestConfig" )
    net.SendToServer()
    tempID = tempID + 1
    local hookID = tempID
    hook.Add( "MapVote_ConfigRecieved", "Temp_" .. hookID, function( config )
        hook.Remove( "MapVote_ConfigRecieved", "Temp_" .. hookID )
        if cb then
            cb( config )
        end
    end )
end
