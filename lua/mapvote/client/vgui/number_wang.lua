local PANEL = {}

function PANEL:Init()
    self.numberWang = vgui.Create( "DNumberWang", self ) --[[@as DNumberWang]]
    self.numberWang:SetTextColor( Color( 255, 255, 255 ) )
    self.numberWang.m_bBackground = false
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 2, 0, 0, w, h, MapVote.style.secondaryBG )
end

function PANEL:SetMin( val )
    self.numberWang:SetMin( val )
end

function PANEL:SetMax( val )
    self.numberWang:SetMax( val )
end

function PANEL:SetValue( val )
    self.numberWang:SetValue( val )
end

vgui.Register( "MapVote_NumberWang", PANEL, "DPanel" )
