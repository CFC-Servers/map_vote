---@class ConfigPanel : DScrollPanel
local PANEL = {}

function PANEL:Init()
    self.largestLabelWidth = 0
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
    label:SetText( displayName )
    label:Dock( LEFT )
    label:SetFont( "MapVote_ConfigItem" )
    label:SizeToContents()
    self.largestLabelWidth = math.max( self.largestLabelWidth, label:GetWide() )
    optionPanel.label = label
    return optionPanel
end

function PANEL:PerformLayout()
    for _, child in pairs( self:GetCanvas():GetChildren() ) do
        if child.label then
            child.label:SetWide( self.largestLabelWidth + 50 )
        end
    end
end

surface.CreateFont( "MapVote_ConfigItem", {
    font = "Arial",
    size = 20,
    weight = 600,
    antialias = true,
    shadow = false
} )

function PANEL:AddSeperator( text )
    local seperator = vgui.Create( "MapVote_Seperator", self )
    seperator:SetText( text )
    seperator:Dock( TOP )
    seperator:DockMargin( 5, 15, 5, 5 )
    self:AddItem( seperator )
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
        entryPanel = vgui.Create( "MapVote_Switch", optionPanel )
        entryPanel:SetOn( startingValue or false )
        entryPanel.ColorOff = MapVote.style.colorSecondaryFG
        entryPanel.ColorOn = MapVote.style.colorGreen
        entryPanel.ColorSwitch = MapVote.style.colorPrimaryBG
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
        entryPanel:SetMax( itemType.max or 1e10 )
        entryPanel:SetMin( itemType.min or -1e10 )
        entryPanel:SetValue( startingValue or 0 )
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
        entryPanel:SetSize( 300, 25 )
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
        entryPanel:SetEnabled( true )
        entryPanel.OnValueChanged = function( _, val )
            val = string.Split( val, "," )
            for i = 1, #val do
                val[i] = string.Trim( val[i] )
            end
            PrintTable( val )
            local ok, err = itemType:Validate( val )
            errLabel:SetText( err or "" )
            errLabel:Dock( LEFT )
            if ok then
                action( val )
            end
        end
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
