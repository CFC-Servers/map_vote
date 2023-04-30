---@class SearchableScrollPanel : DScrollPanel
local PANEL = {}
function PANEL:Init()
    self.items = {}
    self.filter = ""
end

function PANEL:SetSearch( filter )
    self.filter = filter
end

---@param entry Panel
function PANEL:BindToEntry( entry )
    entry.OnValueChanged = function( _, value )
        timer.Create( "MapVote_SearchableScrollPanel_Refresh", 0.5, 1, function()
            self:SetSearch( value )
            self:Refresh()
        end ) -- this means that the search will only refresh after 2 seconds of no typing
    end
end

---@param name string
---@param f fun(): Panel
function PANEL:AddNamedPanel( name, f )
    table.insert( self.items, {
        name = name,
        f = f
    } )
end

---@param name string
---@protected
function PANEL:PassesFilter( name )
    return string.find( name, self.filter ) ~= nil
end

function PANEL:Refresh()
    self:Clear()
    for _, item in ipairs( self.items ) do
        if self:PassesFilter( item.name ) then
            self:Add( item.f() )
        end
    end
end

vgui.Register( "MapVote_SearchableScrollPanel", PANEL, "DScrollPanel" )
