---@class MapVote_MapIcon : Panel
local PANEL = {}

function PANEL:Init()
    self.button = vgui.Create( "DImageButton", self ) --[[@as DImageButton]]
    self.button:Dock( FILL )
    self.button:DockMargin( 1, 1, 1, 0 )
    self.button.DoClick = function()
        self:DoClick()
    end

    self.infoRow = vgui.Create( "Panel", self.button ) --[[@as DPanel]]
    self.infoRow:Dock( BOTTOM )
    self.infoRow:SetTall( 20 )
    self.infoRow.Paint = function( _, w, h )
        surface.SetDrawColor( Color( MapVote.style.colorSecondaryFG.r, MapVote.style.colorSecondaryFG.g, MapVote.style.colorSecondaryFG.b, 230 ) )
        surface.DrawRect( 0, 0, w, h )
    end

    self.label = vgui.Create( "DLabel", self.infoRow ) --[[@as DLabel]]
    self.label:Dock( LEFT )
    self.label:DockMargin( 5, 0, 0, 0 )
    self.label:SetContentAlignment( 4 )
    self.label:SetFont( "DermaDefaultBold" )
end

function PANEL:DoClick()
    -- override me
end

function PANEL:Paint( w, h )
    surface.SetDrawColor( MapVote.style.colorSecondaryFG )
    surface.DrawRect( 0, 0, w, h )
end

function PANEL:SetMap( map )
    self.label:SetText( map )
    self.label:SizeToContents()
    self.label:SetWide( math.min( self.label:GetWide(), self:GetWide() - 5 ) )

    MapVote.ThumbDownloader:QueueDownload( map, function( filepath )
        MapVote.TaskManager.AddFunc( function()
            ---@diagnostic disable-next-line: missing-parameter
            self.button:SetImage( filepath )
        end )
    end )
end

vgui.Register( "MapVote_MapIcon", PANEL, "Panel" )
