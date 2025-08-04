---@class MapVote_MapIcon : Panel
local PANEL = {}


local fontCreated = {}
local function iconFont( size )
    -- no smaller  than 10
    size = math.max( size, 10 )
    if fontCreated["MapVote_MapIcon" .. size] then
        return "MapVote_MapIcon" .. size
    end
    local name = "MapVote_MapIcon" .. size
    surface.CreateFont( name, {
        font = "Arial",
        size = size,
        weight = 600,
        antialias = true,
        shadow = true,
    } )
    fontCreated[name] = true
    return name
end

function PANEL:Init()
    self.button = vgui.Create( "DImageButton", self ) --[[@as DImageButton]]
    self.button:Dock( FILL )
    self.button:DockMargin( 1, 1, 1, 0 )
    self.button.DoClick = function()
        self:DoClick()
    end

    self.infoRow = vgui.Create( "Panel", self.button ) --[[@as DPanel]]
    if MapVote.style.bottomUpIconFilling then
        self.infoRow:Dock( TOP )
    else
        self.infoRow:Dock( BOTTOM )
    end
    self.infoRow:SetTall( 40 )
    self.infoRow.Paint = function( _, w, h )
    end

    self.shadow = vgui.Create( "DLabel", self.infoRow )
    self.shadow:DockMargin( 5, 0, 0, 0 )
    self.shadow:SetContentAlignment( 4 )
    self.shadow:SetFont( iconFont( 20 ) )
    self.shadow:SetTextColor( MapVote.style.colorTextShadow )

    self.label = vgui.Create( "DLabel", self.infoRow ) --[[@as DLabel]]
    self.label:Dock( LEFT )
    self.label:DockMargin( 5, 0, 0, 0 )
    self.label:SetContentAlignment( 4 )
    self.label:SetFont( iconFont( 20 ) )
    self.label:SizeToContents()
    self.label:SetTextColor( MapVote.style.colorTextPrimary )

    self.label:SetZPos( 10001 )
    self.shadow:SetZPos( 10001 )

    self.percentLabel = vgui.Create( "DLabel", self.button ) --[[@as DLabel]]
    self.percentLabel:DockMargin( 5, 0, 0, 0 )
    self.percentLabel:SetContentAlignment( 4 )
    self.percentLabel:SetFont( iconFont( 25 ) )
    self.percentLabel:SetTextColor( MapVote.style.colorTextPrimary )
    self.percentLabel:SetText( "0%" )
    if MapVote.style.bottomUpIconFilling then
        self.percentLabel:Dock( TOP )
    else
        self.percentLabel:Dock( BOTTOM )
    end
end

function PANEL:DoClick()
    -- override me
end

function PANEL:SetPercent( percent )
    if percent < 0 or percent > 100 then
        error( "Percent must be between 0 and 100" )
    end
    self.percentLabel:SetText( string.format( "%d%%", math.floor( percent ) ) )
    self.percentLabel:SizeToContents()
end

function PANEL:PerformLayout( w, h )
    local padding = 75
    local baseFontSize = w * 0.10

    surface.SetFont( iconFont( baseFontSize ) )
    local textW, _ = surface.GetTextSize( self.label:GetText() )
    if textW > (w - padding) then
        -- this isnt the best solution, results in alot of unused font creation
        -- if an entirely math based solution can be devised that would be ideal
        -- maybe writing the icon to a material and drawing it with a textured rect that can then be scaled while maintaining aspect ratio
        local startingFontSize = baseFontSize
        for i = startingFontSize, 5, -1 do
            baseFontSize = i
            surface.SetFont( iconFont( baseFontSize ) )
            textW, _ = surface.GetTextSize( self.label:GetText() )
            if textW <= (w - padding) then
                break
            end
        end
    end

    self.label:SetFont( iconFont( baseFontSize ) )
    self.label:SizeToContents()
    self.infoRow:SetTall( self.label:GetTall() + 10 )

    self.shadow:SetFont( iconFont( baseFontSize ) )
    self.shadow:SetText( self.label:GetText() )
    self.shadow:SizeToContents()
    self.shadow:SetPos( self.label:GetPos() + 2, self.label:GetPos() + 2 )
end

function PANEL:Paint( w, h )
    surface.SetDrawColor( MapVote.style.colorSecondaryFG )
    surface.DrawRect( 0, 0, w, h )
end

function PANEL:SetMap( map )
    self.label:SetText( map )
    self.label:SizeToContents()
    self.label:SetWide( math.min( self.label:GetWide(), self:GetWide() - 5 ) )

    MapVote.ThumbDownloader:QueueDownload( map, function( material )
        MapVote.TaskManager.AddFunc( function()
            ---@diagnostic disable-next-line: missing-parameter
            self.button:SetMaterial( material )
        end )
    end )
end

vgui.Register( "MapVote_MapIcon", PANEL, "Panel" )
