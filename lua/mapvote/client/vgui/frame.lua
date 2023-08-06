---@class MapVote_Frame : DFrame
local PANEL = {}

local function disableColor( c )
    return Color( c.r / 2, c.g / 2, c.b / 2 )
end

local function drawCircle( x, y, radius, seg )
    draw.NoTexture()
    local cir = {}

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( (i / seg) * -360 )
        table.insert( cir,
            {
                x = x + math.sin( a ) * radius,
                y = y + math.cos( a ) * radius,
            } )
    end

    local a = math.rad( 0 ) -- This is needed for non absolute segment counts
    table.insert( cir,
        {
            x = x + math.sin( a ) * radius,
            y = y + math.cos( a ) * radius,
        } )

    surface.DrawPoly( cir )
end
function surface.DrawTexturedRectRotatedPoint( x, y, w, h, rot, x0, y0 )
    local c = math.cos( math.rad( rot ) )
    local s = math.sin( math.rad( rot ) )

    local newx = y0 * s - x0 * c
    local newy = y0 * c + x0 * s

    surface.DrawTexturedRectRotated( x + newx, y + newy, w, h, rot )
end

function PANEL:SetHideOnClose( hide )
    self.hideOnClose = hide
end

function PANEL:Init()
    local blur = MapVote.style.frameBlur or 0
    if blur > 0 then
        self.blurMat = Material( "pp/blurscreen" )
        self.blurMat:SetFloat( "$blur", blur )
        self.blurMat:Recompute()
    end

    local circleSegments = 30
    self.btnClose:SetSize( 25, 25 )
    ---@diagnostic disable-next-line: duplicate-set-field
    self.btnClose.Paint = function( _, w, h )
        local r = (w - 13) / 2
        surface.SetDrawColor( MapVote.style.colorCloseButton )
        drawCircle( w / 2, h / 2 + 2, r, circleSegments )
        surface.SetDrawColor( MapVote.style.colorTextPrimary )
        surface.DrawTexturedRectRotatedPoint( w / 2, h / 2 + 2, r * 1.5, 2, 45, 0, 0 )
        surface.DrawTexturedRectRotatedPoint( w / 2, h / 2 + 2, r * 1.5, 2, 315, 0, 0 )
    end

    self.btnMaxim:SetSize( 25, 25 )
    ---@diagnostic disable-next-line: duplicate-set-field
    self.btnMaxim.Paint = function( _, w, h )
        local r = (w - 13) / 2
        surface.SetDrawColor( disableColor( MapVote.style.colorGreen ) )
        drawCircle( w / 2, h / 2 + 2, r, circleSegments )
    end

    self.btnMinim:SetSize( 25, 25 )
    ---@diagnostic disable-next-line: duplicate-set-field
    self.btnMinim.Paint = function( _, w, h )
        local r = (w - 13) / 2
        surface.SetDrawColor( disableColor( MapVote.style.colorYellow ) )
        drawCircle( w / 2, h / 2 + 2, r, circleSegments )
    end
    self.btnClose.DoClick = function()
        if self.hideOnClose then
            self:SetVisible( false )
            return
        end

        self:Close()
    end
end

function PANEL:Paint( w, h )
    for _ = 1, MapVote.style.frameBackgroundBlur do
        Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
    end
    self:ApplyBlur()
    draw.RoundedBox( MapVote.style.frameCornerRadius, 0, 0, w, h, MapVote.style.colorPrimaryBG )
end

function PANEL:ApplyBlur()
    if not self.blurMat then return end

    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( self.blurMat )

    render.UpdateScreenEffectTexture()

    local x, y = self:LocalToScreen( 0, 0 )
    surface.DrawTexturedRect( -x, -y, ScrW(), ScrH())
end

local basePanel = baseclass.Get( "Panel" )

function PANEL:SetVisible( v )
    self:OnVisibilityChanged( v )
    return basePanel.SetVisible( self, v )
end

function PANEL:OnVisibilityChanged( _ ) end

vgui.Register( "MapVote_Frame", PANEL, "DFrame" )
