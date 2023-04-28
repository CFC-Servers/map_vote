---@class ConfigPanel : DScrollPanel
local PANEL = {}

function PANEL:Init()
end

---@param displayName string
---@param itemType SchemaType
function PANEL:AddConfigItem( displayName, itemType, action, startingValue )
    local w = self:GetWide()
    local optionPanel = vgui.Create( "Panel", self ) --[[@as Panel]]
    optionPanel:SetSize( w, 35 )
    optionPanel:Dock( TOP )

    local label = vgui.Create( "DLabel", optionPanel ) --[[@as DLabel]]
    label:SetText( displayName .. ": " )
    label:Dock( LEFT )
    label:SetSize( label:GetTextSize() )

    local errLabel
    local entryPanel
    if itemType.name == "int" then
        entryPanel = vgui.Create( "DNumberWang", optionPanel ) --[[@as DNumberWang]]
        entryPanel:DockMargin( 0, 5, 0, 5 )
        entryPanel:Dock( LEFT )
        entryPanel:SetSize( 100, 25 )
        entryPanel:SetMax( 1e10 )
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
        -- TODO Do min and max
    elseif itemType.name == "bool" then
        entryPanel = vgui.Create( "DCheckBox", optionPanel ) --[[@as DCheckBox]]
        entryPanel:DockMargin( 0, 5, 0, 5 )
        entryPanel:Dock( LEFT )
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
        entryPanel = vgui.Create( "DNumberWang", optionPanel ) --[[@as DNumberWang]]
        entryPanel:DockMargin( 0, 5, 0, 5 )
        entryPanel:Dock( LEFT )
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
        entryPanel = vgui.Create( "DTextEntry", optionPanel ) --[[@as DTextEntry]]
        entryPanel:DockMargin( 0, 5, 0, 5 )
        entryPanel:Dock( LEFT )
        entryPanel:SetSize( 100, 25 )
        entryPanel:SetValue( startingValue or "" )
        ---@diagnostic disable-next-line: duplicate-set-field
        entryPanel.OnValueChange = function( _, val )
            local ok, err = itemType:Validate( val )
            errLabel:SetText( err or "" )
            errLabel:Dock( LEFT )
            if ok then
                action( val )
            end
        end
    end
    errLabel = vgui.Create( "DLabel", optionPanel ) --[[@as DLabel]]
    errLabel:SetText( "" )
    errLabel:Dock( LEFT )
    errLabel:SetSize( 500, 25 )
    errLabel:SetColor( Color( 255, 0, 0 ) )

    if not entryPanel then
        error( "Unknown type " .. itemType.name )
    end
    self:AddItem( optionPanel )
end

vgui.Register( "MapVote_ConfigPanel", PANEL, "DScrollPanel" )
