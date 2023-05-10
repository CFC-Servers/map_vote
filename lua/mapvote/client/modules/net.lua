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

    MapVote.Panel = MapVote.OpenPanel( MapVote.currentMaps )
    MapVote.Panel.voteArea:SetMaps( MapVote.currentMaps )

    -- TODO move this into plugin/integration
    hook.Add( "CFC_DisconnectInterface_ShouldShowInterface", "MapVote_DisableDisconnectInterface", function()
        return false
    end )
end )

net.Receive( "MapVote_PlayerChangedVote", function()
    local ply = net.ReadEntity() --[[@as Player]]
    if not IsValid( ply ) then return end
    if not IsValid( MapVote.Panel ) then return end
    local mapID = net.ReadUInt( 32 )
    local mapData = MapVote.Panel.voteArea:GetMapDataByIndex( mapID )

    MapVote.Panel.voteArea:SetVote( ply, mapData.map )
end )

net.Receive( "MapVote_VoteFinished", function()
    if IsValid( MapVote.Panel ) then
        -- TODO flash
        -- MapVote.Panel:Flash( net.ReadUInt( 32 ) )
    end
end )

net.Receive( "MapVote_VoteCancelled", function()
    if IsValid( MapVote.Panel ) then MapVote.Panel:Remove() end

    -- TODO move this into plugin/integration
    hook.Remove( "CFC_DisconnectInterface_ShouldShowInterface", "MapVote_DisableDisconnectInterface" )
end )

net.Receive( "RTV_Delay", function()
    chat.AddText( Color( 102, 255, 51 ), "[RTV]", Color( 255, 255, 255 ),
        " The vote has been rocked, map vote will begin on round end" )
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
