MapVote._mapConfigFrame = nil
MapVote._mapConfigFramescrollPanel = nil
function MapVote.OpenMapConfig()
    if MapVote._mapConfigFrame then
        return
    end

    local frame = vgui.Create( "DFrame" ) --[[@as DFrame]]

    frame:SetSize( 800, 600 )
    frame:Center()
    frame:MakePopup()

    ---@diagnostic disable-next-line: duplicate-set-field
    frame.OnClose = function( _ )
        MapVote._mapConfigFrame = nil
        MapVote._mapConfigFramescrollPanel = nil
        MapVote.Net.SendConfig()
    end
    MapVote._mapConfigFrame = frame

    local scrollPanel = vgui.Create( "DScrollPanel", frame ) --[[@as DScrollPanel]]
    scrollPanel:Dock( FILL )
    MapVote._mapConfigFramescrollPanel = scrollPanel

    MapVote.Net.SendConfigRequest( function()
        MapVote.Config.IncludedMaps["coastal_complex"] = true
        MapVote.Config.ExcludedMaps["de_beroth_beta"] = true
        MapVote.populateScrollPanel()
    end )
    MapVote.Net.SendMapListRequest( function( _ )
        MapVote.populateScrollPanel()
    end )
end

function MapVote.populateScrollPanel()
    if not MapVote._mapConfigFramescrollPanel then
        return
    end
    local scrollPanel = MapVote._mapConfigFramescrollPanel
    scrollPanel:Clear()
    for _, map in pairs( MapVote.FullMapList or {} ) do
        local row = vgui.Create( "DPanel", scrollPanel ) --[[@as DPanel]]
        row:SetSize( 800, 128 )

        local mapIcon = vgui.Create( "MapVote_MapIcon", row ) --[[@as MapIcon]]
        mapIcon:SetSize( 128, 128 )
        mapIcon:SetMap( map )
        mapIcon:Dock( LEFT )

        local selectButtons = vgui.Create( "MapVote_3StateSelect", row ) --[[@as ThreeStateSelect]]
        selectButtons:SetSize( 128, 128 )
        selectButtons:Dock( LEFT )

        if MapVote.Config then
            ---@diagnostic disable-next-line: duplicate-set-field
            selectButtons.OnStateChange = function( _, state )
                if state == 1 then
                    MapVote.Config.IncludedMaps[map] = true
                    MapVote.Config.ExcludedMaps[map] = nil
                elseif state == -1 then
                    MapVote.Config.IncludedMaps[map] = nil
                    MapVote.Config.ExcludedMaps[map] = true
                else
                    MapVote.Config.IncludedMaps[map] = nil
                    MapVote.Config.ExcludedMaps[map] = nil
                end
            end

            if MapVote.Config.IncludedMaps[map] then
                selectButtons:SetState( 1 )
            elseif MapVote.Config.ExcludedMaps[map] then
                selectButtons:SetState( -1 )
            else
                selectButtons:SetState( 0 )
            end
        end

        local DButton = scrollPanel:Add( row )
        DButton:Dock( TOP )
        DButton:DockMargin( 0, 0, 0, 5 )
    end

    MapVote.ThumbDownloader:RequestWorkshopIDs()
end

MapVote.OpenMapConfig()
