---@class MapVote_Seperator : DPanel
local PANEL = {}

surface.CreateFont( "MapVote_Seperator", {
    font = "Arial",
    size = 30,
    weight = 600,
    antialias = true,
    shadow = false
} )

function PANEL:Init()
    self:SetTall( 1 )
    self.text = ""
    self.title = nil
    self.divider = vgui.Create( "DPanel", self )
    self.divider:SetTall( 1 )
    self.divider.Paint = function( _, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
    end
    self.divider:DockMargin( 0, 1, 0, 0 )
    self.divider:Dock( BOTTOM )
    self:SetTall( 40 )
end

function PANEL:SetText( text )
    if text == nil and self.title then
        self.title:Remove()
        self.title = nil
        return
    elseif text == nil then
        return
    end

    if self.title then
        self.title:SetText( text )
    else
        self.title = vgui.Create( "DLabel", self )
        self.title:SetText( text )
        self.title:SetFont( "MapVote_Seperator" )
        self.title:Dock( TOP )
        self.title:SizeToContents()
    end

    self:InvalidateLayout( true )
    self:SizeToChildren( false, true )
end

vgui.Register( "MapVote_Seperator", PANEL, "Panel" )
