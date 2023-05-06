util.AddNetworkString( "MapVote_WorkshopIDTable" )
util.AddNetworkString( "MapVote_RequestWorkshopIDTable" )

function MapVote.getAllWorkshopIDs()
    local addonWorkshopIDs = {}
    for _, addon in ipairs( engine.GetAddons() ) do
        local files = file.Find( "maps/*.bsp", addon.title )
        for _, f in ipairs(files) do
            addonWorkshopIDs[string.Replace( f, ".bsp", "" )] = addon.wsid
        end
    end
    MapVote.addonWorkshopIDs = addonWorkshopIDs
end

net.Receive( "MapVote_RequestWorkshopIDTable", function( _, ply )
    local requestedMaps = net.ReadTable()
    local addonWorkshopIDs = {}
    for _, map in ipairs( requestedMaps ) do
        if MapVote.addonWorkshopIDs[map] then
            addonWorkshopIDs[map] = MapVote.addonWorkshopIDs[map]
        end
    end
    net.Start( "MapVote_WorkshopIDTable" )
    net.WriteTable( addonWorkshopIDs )
    net.Send( ply )
end )
hook.Add( "Initialize", "MapVote_GetWorkshopIDs", MapVote.getAllWorkshopIDs )
