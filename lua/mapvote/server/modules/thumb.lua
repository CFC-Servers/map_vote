util.AddNetworkString( "MapVote_WorkshopIDTable" )

function MapVote.getAllWorkshopIDs()
    local addonWorkshopIDs = {}
    for _, addon in ipairs( engine.GetAddons() ) do
        local files = file.Find( "maps/*.bsp", addon.title )
        if #files > 0 then
            addonWorkshopIDs[string.Replace( files[1], ".bsp", "" )] = addon.wsid
        end
    end
    MapVote.addonWorkshopIDs = addonWorkshopIDs
end

hook.Add( "PlayerInitialSpawn", "MapVote_SendWorkshopIDTable", function( ply )
    net.Start( "MapVote_WorkshopIDTable" )
    net.WriteTable( MapVote.addonWorkshopIDs )
    net.Send( ply )
end )
hook.Add( "Initialize", "MapVote_GetWorkshopIDs", MapVote.getAllWorkshopIDs )
