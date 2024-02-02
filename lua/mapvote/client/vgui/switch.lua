---@class MapVote_Switch : DButton
local PANEL = {}

function PANEL:Init()
    self:SetSize( 40, 22 )
    self:SetText( "" )
    self.On = false
    self.LastClicked = 0
    self.ColorOff = Color( 50, 50, 50 )
    self.ColorOn = Color( 250, 250, 250 )
    self.ColorSwitch = Color( 5, 5, 5 )
end

function PANEL:Toggle()
    self.On = not self.On
    self:OnChange( self.On )
end

function PANEL:GetOn()
    return self.On
end

function PANEL:SetOn( on )
    self.On = on
    self:OnChange( self.On )
end

function PANEL:OnChange( on )
end

function PANEL:Paint( w, h )
    if self.On then
        draw.RoundedBox( 180, 0, 0, w, h, self.ColorOn )
    else
        draw.RoundedBox( 180, 0, 0, w, h, self.ColorOff )
    end

    local timeSince = SysTime() - self.LastClicked
    local fraction = math.min( timeSince / 0.2, 1 )
    if self.On then
        local x = Lerp( fraction, 0, (w - h) )
        draw.RoundedBox( 180, x + 2, 2, h - 4, h - 4, self.ColorSwitch )
    else
        local x = Lerp( fraction, (w - h), 0 )
        draw.RoundedBox( 180, x + 2, 2, h - 4, h - 4, self.ColorSwitch )
    end
end

function PANEL:DoClick()
    self:Toggle()
    self.LastClicked = SysTime()
end

vgui.Register( "MapVote_Switch", PANEL, "DButton" )
