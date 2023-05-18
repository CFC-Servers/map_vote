local schema = MapVote.configSchema

local function updateconfigKey( key )
    return function( value )
        if MapVote.config then
            MapVote.config[key] = value
        end
    end
end

local configMenuOptions = {
    { "Map Limit",                        schema.fields.MapLimit,                  "MapLimit" },
    { "Time Limit",                       schema.fields.TimeLimit,                 "TimeLimit" },
    { "Allow Current Map",                schema.fields.AllowCurrentMap,           "AllowCurrentMap" },
    { "RTV Percent Players Required 0-1", schema.fields.RTVPercentPlayersRequired, "RTVPercentPlayersRequired" },
    { "RTV Wait",                         schema.fields.RTVWait,                   "RTVWait" },
    { "Sort Maps",                        schema.fields.SortMaps,                  "SortMaps" },
    { "Default Map",                      schema.fields.DefaultMap,                "DefaultMap" },
    { "Enable Cooldown",                  schema.fields.EnableCooldown,            "EnableCooldown" },
    { "Maps Before Revote",               schema.fields.MapsBeforeRevote,          "MapsBeforeRevote" },
    { "RTV Player Count",                 schema.fields.RTVPlayerCount,            "RTVPlayerCount" },
    { "Minimum Players Before Reset",     schema.fields.MinimumPlayersBeforeReset, "MinimumPlayersBeforeReset" },
    { "Time To Reset",                    schema.fields.TimeToReset,               "TimeToReset" },
    { "Map Prefixes",                     schema.fields.MapPrefixes,               "MapPrefixes" },
}

MapVote._mapconfigFrame = nil
MapVote._mapconfigFramescrollPanel = nil

MapVote._configFrame = nil
function MapVote.openconfig()
    if IsValid( MapVote._configFrame ) then
        return
    end
    local frame = vgui.Create( "MapVote_Frame" ) --[[@as DFrame]]
    frame:SetSize( 800, 600 )
    frame:Center()
    frame:MakePopup()
    frame:SetTitle( "MapVote Config" )

    MapVote._configFrame = frame
    local configMenu = vgui.Create( "MapVote_ConfigPanel", frame ) --[[@as ConfigPanel]]
    configMenu:SetSize( 800, 600 )
    configMenu:Dock( FILL )

    ---@diagnostic disable-next-line: duplicate-set-field
    frame.OnClose = function( _ )
        if IsValid( MapVote._mapconfigFrame ) then
            MapVote._mapconfigFrame:Remove()
        end
        MapVote.Net.sendConfig()
    end

    MapVote.Net.sendConfigRequest( function()
        configMenu:Clear()
        for _, option in pairs( configMenuOptions ) do
            if IsValid( configMenu ) and configMenu.AddConfigItem then
                configMenu:AddConfigItem( option[1], option[2], updateconfigKey( option[3] ), MapVote.config[option[3]] )
            end
        end

        local buttonOpenMaps = vgui.Create( "DButton" ) --[[@as DButton]]
        buttonOpenMaps:SetText( "Open Map config" )
        buttonOpenMaps:Dock( LEFT )
        buttonOpenMaps:SetWide( 200 )

        ---@diagnostic disable-next-line: duplicate-set-field
        buttonOpenMaps.DoClick = function( _ )
            MapVote.openMapconfig()
        end
        configMenu:AddConfigPanel( "Edit map selection", buttonOpenMaps )
    end )
end

function MapVote.openMapconfig()
    if IsValid( MapVote._mapconfigFrame ) then
        return
    end

    local frame = vgui.Create( "MapVote_Frame" ) --[[@as DFrame]]
    frame:SetSize( 800, 600 )
    frame:Center()
    frame:MakePopup()

    ---@diagnostic disable-next-line: duplicate-set-field
    frame.OnClose = function( _ )
        MapVote._mapconfigFrame = nil
        MapVote._mapconfigFramescrollPanel = nil
    end
    MapVote._mapconfigFrame = frame
    local textEntry = vgui.Create( "MapVote_TextEntry", frame ) --[[@as DTextEntry]]
    textEntry:Dock( TOP )
    textEntry:DockMargin( 15, 5, 15, 5 )
    textEntry:SetPlaceholderText( "Search for a map..." )

    local scrollPanel = vgui.Create( "MapVote_SearchableScrollPanel", frame ) --[[@as SearchableScrollPanel]]
    scrollPanel:Dock( FILL )
    scrollPanel:BindToEntry( textEntry )
    scrollPanel:DockMargin( 15, 5, 15, 5 )

    MapVote._mapconfigFramescrollPanel = scrollPanel

    MapVote.Net.sendMapListRequest( function( _ )
        MapVote.populateScrollPanel()
    end )
end

function MapVote.addMapRow( map )
    local row = vgui.Create( "Panel" ) --[[@as Panel]]
    row:SetSize( 800, 128 )

    local mapIcon = vgui.Create( "MapVote_MapIcon", row ) --[[@as MapIcon]]
    mapIcon:SetSize( 128, 128 )
    mapIcon:SetMap( map )
    mapIcon:Dock( LEFT )

    local selectContainer = vgui.Create( "Panel", row ) --[[@as Panel]]
    selectContainer:Dock( LEFT )
    selectContainer:SetSize( 100, 128 )

    local selectButtons = vgui.Create( "MapVote_3StateSelect", selectContainer ) --[[@as ThreeStateSelect]]
    selectButtons:Dock( TOP )
    selectButtons:DockMargin( 5, 0, 5, 0 )
    selectButtons:DockPadding( 1, 1, 1, 1 )
    selectButtons:SetSize( 300, 128 )
    selectButtons:SetSize( 100, selectButtons:GetButtonsHeight() )

    ---@diagnostic disable-next-line: duplicate-set-field
    selectButtons.OnStateChange = function( _, state )
        if state == 1 then
            MapVote.config.IncludedMaps[map] = true
            MapVote.config.ExcludedMaps[map] = nil
        elseif state == -1 then
            MapVote.config.IncludedMaps[map] = nil
            MapVote.config.ExcludedMaps[map] = true
        else
            MapVote.config.IncludedMaps[map] = nil
            MapVote.config.ExcludedMaps[map] = nil
        end
    end

    if MapVote.config.IncludedMaps[map] then
        selectButtons:SetState( 1 )
    elseif MapVote.config.ExcludedMaps[map] then
        selectButtons:SetState( -1 )
    else
        selectButtons:SetState( 0 )
    end

    local infoPanel = vgui.Create( "Panel", row ) --[[@as Panel]]
    infoPanel:SetSize( 200, row:GetTall() )

    local label = vgui.Create( "DLabel", infoPanel ) --[[@as DLabel]]
    label:SetText( map )
    label:DockMargin( 5, 0, 0, 0 )
    label:SetSize( label:GetTextSize() )
    label:Dock( TOP )
    infoPanel:Dock( LEFT )

    row:Dock( TOP )
    row:DockMargin( 5, 5, 5, 5 )

    return row
end

function MapVote.populateScrollPanel()
    if not IsValid( MapVote._mapconfigFramescrollPanel ) then
        return
    end
    local scrollPanel = MapVote._mapconfigFramescrollPanel
    scrollPanel:Clear()

    if not MapVote.config then return end

    for _, map in pairs( MapVote.fullMapList or {} ) do
        scrollPanel:AddNamedPanel( map, function()
            return MapVote.addMapRow( map )
        end )
    end
    scrollPanel:Refresh()
    MapVote.ThumbDownloader:RequestWorkshopIDs()
end

concommand.Add( "mapvote_config", MapVote.openconfig )
