local searchPaths = {
    "maps/thumb",
    "maps/thumb/",
    "maps/",
    "data/mapvote/thumb_cache/",
}

local noIcon = "maps/thumb/noicon.png"
local thumbFilePathCache = {}

local function getMapThumbnail( name )
    if thumbFilePathCache[name] then
        return thumbFilePathCache[name]
    end

    for _, path in ipairs( searchPaths ) do
        -- finding all the paths in bulk this way is faster than using file.Exists
        local thumbs = file.Find( path .. "*", "GAME" )
        for _, thumb in ipairs( thumbs ) do
            local extensionName = string.sub( thumb, -3, -1 )
            if extensionName == "png" or extensionName == "jpg" then
                local mapName = string.sub( thumb, 1, -5 )
                thumbFilePathCache[mapName] = path .. thumb
            end
        end
    end

    return thumbFilePathCache[name]
end


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

    local thumbNail = getMapThumbnail( map )
    if thumbNail == nil then
        self:OnMissingMapThumbnail( map )
    end

    MapVote.TaskManager.AddFunc( function()
        ---@diagnostic disable-next-line: missing-parameter
        self.button:SetImage( thumbNail or noIcon )
    end )
end

function PANEL:OnMissingMapThumbnail( map )
    MapVote.ThumbDownloader:QueueDownload( map, function( filepath )
        MapVote.TaskManager.AddFunc( function()
            ---@diagnostic disable-next-line: missing-parameter
            self.button:SetImage( filepath or noIcon )
        end )
    end )
end

vgui.Register( "MapVote_MapIcon", PANEL, "Panel" )
