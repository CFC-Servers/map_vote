util.AddNetworkString( "MapVote_WorkshopIDTable" )
util.AddNetworkString( "MapVote_RequestWorkshopIDTable" )

function MapVote.getAllWorkshopIDs()
    local addonWorkshopIDs = {}
    for _, addon in ipairs( engine.GetAddons() ) do
        if addon.title ~= "Cached Addon" then
            local files = file.Find( "maps/*.bsp", addon.title )
            for _, f in ipairs( files ) do
                addonWorkshopIDs[string.Replace( f, ".bsp", "" )] = addon.wsid
            end
        end
    end
    MapVote.addonWorkshopIDs = addonWorkshopIDs
end

function MapVote.getWorkshopIDs( maps )
    local addonWorkshopIDs = {}
    for _, map in ipairs( maps ) do
        if MapVote.addonWorkshopIDs[map] then
            addonWorkshopIDs[map] = MapVote.addonWorkshopIDs[map]
        else
            print( "MapVote: No workshop ID found for map", map )
        end
    end
    return addonWorkshopIDs
end

hook.Add( "Initialize", "MapVote_GetWorkshopIDs", MapVote.getAllWorkshopIDs )
