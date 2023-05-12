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
    MapVote.currentMaps = {}
    MapVote.isInProgress = true
    MapVote.votes = {}

    local amt = net.ReadUInt( 32 )
    for _ = 1, amt do
        local map = net.ReadString()
        net.ReadUInt( 32 ) -- this is playcount, TODO
        table.insert( MapVote.currentMaps, map )
    end

    MapVote.EndTime = CurTime() + net.ReadUInt( 32 )

    if IsValid( MapVote.Panel ) then MapVote.Panel:Remove() end

    MapVote.OpenPanel( MapVote.currentMaps, MapVote.EndTime )

    hook.Run( "MapVote_VoteStarted" )
end )

net.Receive( "MapVote_PlayerChangedVote", function()
    local ply = net.ReadEntity() --[[@as Player]]
    local mapID = net.ReadUInt( 32 )

    if not IsValid( ply ) then return end
    if not IsValid( MapVote.Panel ) then return end

    local mapData = MapVote.Panel.voteArea:GetMapDataByIndex( mapID )

    MapVote.Panel.voteArea:SetVote( ply, mapData.map )
end )

net.Receive( "MapVote_VoteFinished", function()
    if IsValid( MapVote.Panel ) then
        -- TODO flash
        MapVote.Panel.voteArea:Flash( net.ReadUInt( 32 ) )
    end
end )

net.Receive( "MapVote_VoteCancelled", function()
    if IsValid( MapVote.Panel ) then MapVote.Panel:Remove() end

    hook.Run( "MapVote_VoteCancelled" )
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
