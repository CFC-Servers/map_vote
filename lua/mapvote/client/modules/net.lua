MapVote.Net = MapVote.Net or {}
-- receivers
net.Receive( "MapVote_MapList", function()
    local mapList = {}
    local mapCount = net.ReadUInt( 32 )
    for i = 1, mapCount do
        mapList[i] = net.ReadString()
    end

    MapVote.FullMapList = mapList
    hook.Run( "MapVote_MapListRecieved", mapList )
end )

net.Receive( "MapVote_Config", function()
    local config = net.ReadTable()
    print( "Config recieved" )
    print( "TEST" )
    pcl = config
    MapVote.Config = config
    hook.Run( "MapVote_ConfigRecieved", config )
end )

local tempID = 0
-- senders
function MapVote.Net.SendMapListRequest( cb )
    net.Start( "MapVote_RequestMapList" )
    net.SendToServer()

    hook.Add( "MapVote_MapListRecieved", "Temp_" .. tempID, function( mapList )
        tempID = tempID + 1
        hook.Remove( "MapVote_MapListRecieved", "Temp_" .. tempID )
        if cb then
            cb( mapList )
        end
    end )
end

function MapVote.Net.SendConfig()
    net.Start( "MapVote_Config" )
    net.WriteTable( MapVote.Config )
    net.SendToServer()
end

function MapVote.Net.SendConfigRequest( cb )
    net.Start( "MapVote_RequestConfig" )
    net.SendToServer()
    hook.Add( "MapVote_ConfigRecieved", "Temp_" .. tempID, function( config )
        tempID = tempID + 1
        hook.Remove( "MapVote_ConfigRecieved", "Temp_" .. tempID )
        if cb then
            cb( config )
        end
    end )
end
