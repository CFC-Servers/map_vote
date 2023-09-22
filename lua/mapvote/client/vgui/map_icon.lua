---@class MapIcon : Panel
local PANEL = {}

function PANEL:Init()
    self.button = vgui.Create( "DImageButton", self ) --[[@as DImageButton]]
    self.button:Dock( FILL )
    self.button:DockMargin( 2, 2, 2, 0 )
    self.button.DoClick = function()
        self:DoClick()
    end

    self.label = vgui.Create( "DLabel", self ) --[[@as DLabel]]
    self.label:Dock( BOTTOM )
    self.label:SetContentAlignment( 5 )
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

    MapVote.ThumbDownloader:QueueDownload( map, function( filepath )
        MapVote.TaskManager.AddFunc( function()
            ---@diagnostic disable-next-line: missing-parameter
            self.button:SetImage( filepath or noIcon )
        end )
    end )
end

vgui.Register( "MapVote_MapIcon", PANEL, "Panel" )
