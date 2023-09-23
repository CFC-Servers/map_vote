---@class MapVote_VoteFrame : MapVote_Frame
---@field btnMaxim Panel
---@field btnMinim Panel
---@field btnClose Panel
local PANEL = {}

function PANEL:Init()
    self._isMinimized = false
    self.btnClose.DoClick = function()
        self:SetMinimized( true )
    end
end

---@diagnostic disable-next-line: unused-local
function PANEL:OnMinimizedChangeStart( _minimized )
end

---@diagnostic disable-next-line: unused-local
function PANEL:OnMinimizedChangeFinish( _minimized )
end

local function apply( items, func )
    for _, item in pairs( items ) do
        func( item )
    end
end

function PANEL:enableTopBar()
    apply( { self.btnClose, self.btnMaxim, self.btnMinim }, function( b )
        b:SetVisible( true )
        b:SetHeight( 24 )
    end )
    self:DockPadding( 5, 24 + 5, 5, 5 )
end

function PANEL:disableTopBar()
    apply( { self.btnClose, self.btnMaxim, self.btnMinim }, function( b )
        b:SetVisible( false )
        b:SetHeight( 0 )
    end )
    self:DockPadding( 5, 5, 5, 5 )
end

-- We need to hardcode a minimum width for people with tiny resolutions
local minMinimizedWidth = 600
local minimizedHeight = 50

function PANEL:SetMinimized( m )
    if not m and self._isMinimized then
        self:OnMinimizedChangeStart( m )
        self._isMinimized = false

        -- Reset panel appearance
        self:enableTopBar()
        self:MakePopup()
        self:SetKeyboardInputEnabled( false )

        -- move panel back to original position and size
        local targetSize = self._originalSize or Vector( ScrW() * 0.8, ScrH() * 0.85 )
        local targetPos = Vector( ScrW() / 2 - targetSize.x / 2, ScrH() / 2 - targetSize.y / 2 )
        MapVote.DoPanelMove( self, targetPos, targetSize, 0.3, function()
            self:OnMinimizedChangeFinish( m )
        end )
    elseif m and not self._isMinimized then
        self:OnMinimizedChangeStart( m )
        self._isMinimized = true
        local targetSize = Vector( math.max( minMinimizedWidth, ScrW() * 0.4 ), minimizedHeight )
        local targetPos = Vector( ScrW() / 2 - targetSize.x / 2, 20 )
        local data = MapVote.DoPanelMove( self, targetPos, targetSize, 0.3, function()
            if not self._isMinimized then return end
            self:OnMinimizedChangeFinish( m )

            self:disableTopBar()
            self:KillFocus()
            self:SetMouseInputEnabled( false )
            self:SetKeyboardInputEnabled( false )
        end )
        self._originalSize = data.startSize
    end
end

vgui.Register( "MapVote_VoteFrame", PANEL, "MapVote_Frame" )
