---@class ThreeStateSelect : Panel
local PANEL = {}
function PANEL:Init()
    self.state = 0
    self.on = vgui.Create( "DButton", self ) --[[@as DButton]]
    self.on:SetText( "Enable" )
    self.on:Dock( TOP )

    ---@diagnostic disable-next-line: duplicate-set-field
    self.on.DoClick = function()
        self.state = 1
        self:OnStateChange( self.state )
    end
    self.on.Paint = function( _, w, h )
        if self.state == 1 then
            surface.SetDrawColor( 86, 115, 232 )
        else
            surface.SetDrawColor( 150, 150, 150 )
        end
        surface.DrawRect( 0, 0, w, h )
    end

    self.off = vgui.Create( "DButton", self ) --[[@as DButton]]
    self.off:SetText( "Disable" )
    self.off:Dock( TOP )
    ---@diagnostic disable-next-line: duplicate-set-field
    self.off.DoClick = function()
        self.state = -1
        self:OnStateChange( self.state )
    end
    self.off.Paint = function( _, w, h )
        if self.state == -1 then
            surface.SetDrawColor( 86, 115, 232 )
        else
            surface.SetDrawColor( 150, 150, 150 )
        end
        surface.DrawRect( 0, 0, w, h )
    end

    self.clear = vgui.Create( "DButton", self ) --[[@as DButton]]
    self.clear:SetText( "Clear" )
    self.clear:Dock( TOP )
    ---@diagnostic disable-next-line: duplicate-set-field
    self.clear.DoClick = function()
        self.state = 0
        self:OnStateChange( self.state )
    end
    self.clear.Paint = function( _, w, h )
        surface.SetDrawColor( 150, 150, 150 )
        surface.DrawRect( 0, 0, w, h )
    end
end

function PANEL:SetState( state )
    self.state = state
end

function PANEL:OnStateChange( state )
    -- override me
end

vgui.Register( "MapVote_3StateSelect", PANEL, "Panel" )
