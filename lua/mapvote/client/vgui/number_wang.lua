local PANEL = {}

function PANEL:Init()
    self.numberWang = vgui.Create( "DNumberWang", self ) --[[@as DNumberWang]]
    self.numberWang:SetTextColor( MapVote.style.textEntryTextColor )
    self.numberWang.m_bBackground = false

    ---@diagnostic disable-next-line: duplicate-set-field
    self.numberWang.OnValueChanged = function( _, val )
        self:OnValueChanged( val )
    end
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

function PANEL:OnValueChanged( _ )
end

vgui.Register( "MapVote_NumberWang", PANEL, "DPanel" )
