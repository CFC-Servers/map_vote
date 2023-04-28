---@class ThreeStateSelect : Panel
local PANEL = {}
function PANEL:Init()
    self.state = 0

    self.on = self:newStateButton( "Enable", 1 )
    self.off = self:newStateButton( "Disable", -1 )
    self.clear = self:newStateButton( "Clear", 0 )
end

---@protected
function PANEL:newStateButton( name, state )
    local button = vgui.Create( "DButton", self ) --[[@as DButton]]
    button:SetText( name )
    button:Dock( TOP )
    ---@diagnostic disable-next-line: duplicate-set-field
    button.DoClick = function()
        self.state = state
        self:OnStateChange( self.state )
    end
    button.Paint = function( _, w, h )
        if self.state ~= 0 and self.state == state then
            surface.SetDrawColor( 78, 66, 245 )
        else
            surface.SetDrawColor( 150, 150, 150 )
        end
        surface.DrawRect( 0, 0, w, h )
    end
end

function PANEL:SetState( state )
    self.state = state
end

function PANEL:OnStateChange( _ )
    -- override me
end

vgui.Register( "MapVote_3StateSelect", PANEL, "Panel" )
