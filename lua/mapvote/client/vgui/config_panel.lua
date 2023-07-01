---@class ConfigPanel : DScrollPanel
local PANEL = {}

function PANEL:Init()
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 10, 0, 0, w, h, MapVote.style.colorPrimaryBG )
end

function PANEL:AddConfigPanel( displayName, panel )
    local row = self:configRow( displayName )
    panel:SetParent( row )
    self:AddItem( row )
end

function PANEL:configRow( displayName )
    local w = self:GetWide()
    local optionPanel = vgui.Create( "Panel", self ) --[[@as Panel]]
    optionPanel:SetSize( w, 35 )
    optionPanel:Dock( TOP )

    local label = vgui.Create( "DLabel", optionPanel ) --[[@as DLabel]]
    label:SetText( displayName .. ": " )
    label:Dock( LEFT )
    label:SetSize( 200, 35 )
    label:SetFont( MapVote.style.configLabelFont )
    return optionPanel
end

---@param displayName string
---@param itemType SchemaType
function PANEL:AddConfigItem( displayName, itemType, action, startingValue )
    local optionPanel = self:configRow( displayName )
    if itemType.name == "optional" then
        -- TODO handle this
        ---@cast itemType SchemaTypeWithSubType
        itemType = itemType.type
    end

    local errLabel
    local entryPanel
    if itemType.name == "int" then
        itemType = itemType --[[@as SchemaTypeNumber]]

        entryPanel = vgui.Create( "MapVote_NumberWang", optionPanel ) --[[@as DNumberWang]]
        entryPanel:SetSize( 100, 25 )
        entryPanel:SetMax( itemType.max or 1e10 )
        entryPanel:SetMin( itemType.min or -1e10 )
        entryPanel:SetValue( startingValue )
        ---@diagnostic disable-next-line: duplicate-set-field
        entryPanel.OnValueChanged = function( _, val )
            local ok, err = itemType:Validate( val )
            errLabel:SetText( err or "" )
            errLabel:Dock( LEFT )
            if ok then
                action( val )
            end
        end
    elseif itemType.name == "bool" then
        entryPanel = vgui.Create( "DCheckBox", optionPanel ) --[[@as DCheckBox]]
        entryPanel:SetSize( 25, 25 )
        entryPanel:SetValue( startingValue or false )
        ---@diagnostic disable-next-line: duplicate-set-field
        entryPanel.OnChange = function( _, val )
            local ok, err = itemType:Validate( val )
            errLabel:SetText( err or "" )
            errLabel:Dock( LEFT )
            if ok then
                action( val )
            end
        end
    elseif itemType.name == "number" then
        itemType = itemType --[[@as SchemaTypeNumber]]

        entryPanel = vgui.Create( "MapVote_NumberWang", optionPanel ) --[[@as DNumberWang]]
        entryPanel:SetValue( startingValue or 0 )
        entryPanel:SetMax( itemType.max or 1e10 )
        entryPanel:SetMin( itemType.min or -1e10 )
        ---@diagnostic disable-next-line: duplicate-set-field
        entryPanel.OnValueChanged = function( _, val )
            local ok, err = itemType:Validate( val )
            errLabel:SetText( err or "" )
            errLabel:Dock( LEFT )
            if ok then
                action( val )
            end
        end
        entryPanel:SetSize( 100, 25 )
    elseif itemType.name == "string" then
        entryPanel = vgui.Create( "MapVote_TextEntry", optionPanel ) --[[@as DTextEntry]]
        entryPanel:SetSize( 100, 25 )
        entryPanel:SetValue( startingValue or "" )

        ---@diagnostic disable-next-line: duplicate-set-field
        entryPanel.OnValueChanged = function( _, val )
            local ok, err = itemType:Validate( val )
            errLabel:SetText( err or "" )
            errLabel:Dock( LEFT )
            if ok then
                action( val )
            end
        end
    elseif itemType.name == "list" then
        if startingValue then
            startingValue = table.concat( startingValue, ", " )
        end
        entryPanel = vgui.Create( "MapVote_TextEntry", optionPanel ) --[[@as DTextEntry]]
        entryPanel:SetSize( 100, 25 )
        entryPanel:SetValue( startingValue or "" )
        entryPanel:SetEnabled( false )
    else
        error( "Unknown type " .. itemType.name )
    end
    entryPanel:Dock( LEFT )
    entryPanel:DockMargin( 0, 5, 0, 5 )

    errLabel = vgui.Create( "DLabel", optionPanel ) --[[@as DLabel]]
    errLabel:SetText( "" )
    errLabel:Dock( LEFT )
    errLabel:SetSize( 500, 25 )
    errLabel:SetColor( MapVote.style.colorRed )

    if not entryPanel then
        error( "Unknown type " .. itemType.name )
    end
    self:AddItem( optionPanel )
end

vgui.Register( "MapVote_ConfigPanel", PANEL, "DScrollPanel" )
