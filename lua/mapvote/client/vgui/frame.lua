local PANEL = {}

local function disableColor( c )
    return Color( c.r / 2, c.g / 2, c.b / 2 )
end

local function drawCircle( x, y, radius, seg )
    local cir = {}

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( (i / seg) * -360 )
        table.insert( cir,
            {
                x = x + math.sin( a ) * radius,
                y = y + math.cos( a ) * radius,
                u = math.sin( a ) / 2 + 0.5,
                v = math.cos( a ) / 2 + 0.5
            } )
    end

    local a = math.rad( 0 ) -- This is needed for non absolute segment counts
    table.insert( cir,
        {
            x = x + math.sin( a ) * radius,
            y = y + math.cos( a ) * radius,
            u = math.sin( a ) / 2 + 0.5,
            v = math.cos( a ) / 2 + 0.5
        } )

    surface.DrawPoly( cir )
end

function PANEL:Init()
    self.btnClose:SetSize( 25, 25 )
    ---@diagnostic disable-next-line: duplicate-set-field
    self.btnClose.Paint = function( _, w, h )
        local r = (w - 13) / 2
        surface.SetDrawColor( MapVote.style.colorRed )
        draw.NoTexture()
        drawCircle( w / 2, h / 2, r, 100 )
    end

    self.btnMaxim:SetSize( 25, 25 )
    ---@diagnostic disable-next-line: duplicate-set-field
    self.btnMaxim.Paint = function( _, w, h )
        local r = (w - 13) / 2
        surface.SetDrawColor( disableColor( MapVote.style.colorGreen ) )
        draw.NoTexture()
        drawCircle( w / 2, h / 2, r, 100 )
    end

    self.btnMinim:SetSize( 25, 25 )
    ---@diagnostic disable-next-line: duplicate-set-field
    self.btnMinim.Paint = function( _, w, h )
        local r = (w - 13) / 2
        surface.SetDrawColor( disableColor( MapVote.style.colorYellow ) )
        draw.NoTexture()
        drawCircle( w / 2, h / 2, r, 100 )
    end
end

function PANEL:Paint( w, h )
    for _ = 1, MapVote.style.frameBlurLevel do
        Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
    end
    draw.RoundedBox( 10, 0, 0, w, h, MapVote.style.colorPrimaryBG )
end

vgui.Register( "MapVote_Frame", PANEL, "DFrame" )
