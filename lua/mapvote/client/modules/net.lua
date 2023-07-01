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
    MapVote.config = net.ReadTable()
    hook.Run( "MapVote_ConfigRecieved", MapVote.config )
end )

net.Receive( "MapVote_VoteStarted", function()
    local maps = {}
    local amt = net.ReadUInt( 32 )
    for _ = 1, amt do
        local map = net.ReadString()
        net.ReadUInt( 32 ) -- this is playcount, TODO
        table.insert( maps, map )
    end

    local endTime = net.ReadUInt( 32 )

    MapVote.StartVote( maps, endTime )
end )

net.Receive( "MapVote_PlayerChangedVote", function()
    local ply = net.ReadEntity() --[[@as Player]]
    local mapIndex = net.ReadUInt( 32 )

    MapVote.ChangeVote( ply, mapIndex )
end )

net.Receive( "MapVote_VoteFinished", function()
    MapVote.FinishVote( net.ReadUInt( 32 ) )
end )

net.Receive( "MapVote_VoteCancelled", function()
    MapVote.CancelVote()
end )

net.Receive( "RTV_Delay", function()
    chat.AddText( Color( 102, 255, 51 ), "[RTV]", Color( 255, 255, 255 ),
        " The vote has been rocked, map vote will begin on round end" )
end )


-- senders
local tempID = 0
function MapVote.Net.sendMapListRequest( cb )
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

function MapVote.Net.sendConfig()
    net.Start( "MapVote_Config" )
    net.WriteTable( MapVote.config )
    net.SendToServer()
end

function MapVote.Net.sendConfigRequest( cb )
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

function MapVote.Net.changeVote( index )
    net.Start( "MapVote_ChangeVote" )
    net.WriteUInt( index, 32 )
    net.SendToServer()
end

function MapVote.Net.requestWorskhopIDs( maps )
    net.Start( "MapVote_RequestWorkshopIDTable" )
    net.WriteTable( maps )
    net.SendToServer()
end

function MapVote.Net.requestState()
    net.Start( "MapVote_RequestVoteState" )
    net.SendToServer()
end
