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
    -- { "Map Prefixes",                     schema.fields.MapPrefixes,               "MapPrefixes" },
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

    MapVote._configFrame = frame
    local configMenu = vgui.Create( "MapVote_ConfigPanel", frame ) --[[@as ConfigPanel]]
    configMenu:SetSize( 800, 600 )
    configMenu:Dock( FILL )

    ---@diagnostic disable-next-line: duplicate-set-field
    frame.OnClose = function( _ )
        if IsValid( MapVote._mapconfigFrame ) then
            MapVote._mapconfigFrame:Remove()
        end
        MapVote.Net.SendConfig()
    end

    MapVote.Net.SendConfigRequest( function()
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

    local scrollPanel = vgui.Create( "DScrollPanel", frame ) --[[@as DScrollPanel]]
    scrollPanel:Dock( FILL )
    MapVote._mapconfigFramescrollPanel = scrollPanel

    MapVote.Net.SendMapListRequest( function( _ )
        MapVote.populateScrollPanel()
    end )
end

function MapVote.addMapRow( scrollPanel, map )
    local row = vgui.Create( "Panel", scrollPanel ) --[[@as Panel]]
    row:SetSize( 800, 128 )

    local mapIcon = vgui.Create( "MapVote_MapIcon", row ) --[[@as MapIcon]]
    mapIcon:SetSize( 128, 128 )
    mapIcon:SetMap( map )
    mapIcon:Dock( LEFT )

    local selectButtons = vgui.Create( "MapVote_3StateSelect", row ) --[[@as ThreeStateSelect]]
    selectButtons:SetSize( 128, 128 )
    selectButtons:Dock( LEFT )

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

    local DButton = scrollPanel:Add( row )
    DButton:Dock( TOP )
    DButton:DockMargin( 0, 0, 0, 5 )
end

function MapVote.populateScrollPanel()
    if not IsValid( MapVote._mapconfigFramescrollPanel ) then
        return
    end
    local scrollPanel = MapVote._mapconfigFramescrollPanel
    scrollPanel:Clear()

    if not MapVote.config then return end

    for _, map in pairs( MapVote.fullMapList or {} ) do
        MapVote.addMapRow( scrollPanel, map )
    end

    MapVote.ThumbDownloader:RequestWorkshopIDs()
end

concommand.Add( "mapvote_config", MapVote.openconfig )
