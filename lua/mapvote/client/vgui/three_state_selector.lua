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
    button:SetTextColor( MapVote.style.textEntryTextColor )
    button:Dock( TOP )
    button:DockMargin( 1, 1, 1, 1 )
    ---@diagnostic disable-next-line: duplicate-set-field
    button.DoClick = function()
        self.state = state
        self:OnStateChange( self.state )
    end
    button.Paint = function( _, w, h )
        if self.state ~= 0 and self.state == state then
            draw.RoundedBox( 3, 0, 0, w, h, MapVote.style.selectedButton )
            return
        end
        draw.RoundedBox( 3, 0, 0, w, h, MapVote.style.secondaryFG )
    end

    return button
end

function PANEL:SetState( state )
    self.state = state
end

function PANEL:OnStateChange( _ )
    -- override me
end

function PANEL:GetButtonsHeight()
    return self.on:GetTall() * 3 + 10
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 3, 0, 0, w, h, MapVote.style.secondaryBG )
end

vgui.Register( "MapVote_3StateSelect", PANEL, "Panel" )
