local avatarSize = 30

local function maxIconSize( w, h, n, _ )
    local px = math.ceil( math.sqrt( n * w / h ) )
    local sx, sy
    if math.floor( px * h / w ) * px < n then
        sx = h / math.ceil( px * h / w )
    else
        sx = w / px
    end

    local py = math.ceil( math.sqrt( n * h / w ) )
    if math.floor( py * w / h ) * py < n then
        sy = w / math.ceil( py * w / h )
    else
        sy = h / py
    end

    if sx < sy then
        return sy, sy
    end
    return sx, sx
end

---@class VoteArea : Panel
local PANEL = {}

function PANEL:Init()
    self.maps = {}
    self.mapIndexes = {}
    self.rows = {}
    self.votes = {}

    self.voteTally = {}
end

function PANEL:Paint()
end

function PANEL:GetMapData( map )
    local index = self.mapIndexes[map]
    return self.maps[index]
end

function PANEL:GetMapDataByIndex( index )
    return self.maps[index]
end

function PANEL:SetMaps( maps )
    self.maps = {}
    for i, map in pairs( maps ) do
        self.mapIndexes[map] = i
        table.insert( self.maps, {
            map = map,
            panel = nil,
            voterCount = 0,
            hiddenCount = 0,
        } )
    end
    self:InvalidateLayout( true )
    self:InvalidateParent( true )
    self:setup()
end

function PANEL:SetVote( ply, mapName )
    local mapData = self:GetMapData( mapName )
    if not mapData then return end

    local iconContainer
    local oldMapData

    if self.votes[ply] then
        local oldMapName = self.votes[ply].mapName
        if oldMapName == mapName then return end
        oldMapData = self:GetMapData( oldMapName )

        oldMapData.voterCount = oldMapData.voterCount - 1

        iconContainer = self.votes[ply].panel
    else
        iconContainer = self:CreateVoterPanel( ply )
    end

    local x, y, show = self:calculateDesiredAvatarIconPosition( mapData )
    iconContainer:SetVisible( true )
    iconContainer:MoveTo( x, y, 0.2, nil, nil, function( _, pnl )
        pnl:SetVisible( show )
    end )

    mapData.voterCount = mapData.voterCount + 1
    self.votes[ply] = {
        mapName = mapName,
        ply = ply,
        panel = iconContainer,
    }
    if not oldMapData then return end
    self:ResetAvatarPositions( oldMapData )
    -- TODO icon container to show number of hidden votes
end

function PANEL:ResetAvatarPositions( mapData )
    mapData.voterCount = 0
    for _, voteData in pairs( self.votes ) do
        if voteData.mapName == mapData.map then
            local x, y, show = self:calculateDesiredAvatarIconPosition( mapData )
            voteData.panel:SetVisible( show )
            voteData.panel:MoveTo( x, y, 0.2, nil, nil, function( _, _ )
            end )
            mapData.voterCount = mapData.voterCount + 1
        end
    end
end

function PANEL:CreateVoterPanel( ply )
    local iconContainer = vgui.Create( "Panel", self )
    local icon = vgui.Create( "AvatarImage", iconContainer ) --[[@as AvatarImage]]
    icon:SetSize( avatarSize, avatarSize )
    icon:SetZPos( 1000 )

    iconContainer.ply = ply
    icon:SetPlayer( ply, avatarSize )

    iconContainer:SetSize( avatarSize + 2, avatarSize + 2 )
    icon:SetPos( 2, 2 )

    iconContainer:SetMouseInputEnabled( false )
    icon:SetAlpha( 200 )

    return iconContainer
end

function PANEL:calculateDesiredAvatarIconPosition( mapData )
    local avatarIconPadding = 1
    local avatarTotalSize = avatarSize + avatarIconPadding * 2

    local mapIcon = mapData.panel
    local maxColumnCount = math.floor( mapIcon:GetWide() / avatarTotalSize )
    local maxRowCount = math.floor( (mapIcon:GetTall() - 10) / avatarTotalSize )

    -- calulate position of mapIcon relative to main vote area panel
    local rowX, rowY = mapIcon.row:GetPos()
    local iconX, iconY = mapIcon:GetPos()
    local x, y = rowX + iconX, rowY + iconY

    local nextRowNumber = math.floor( mapData.voterCount / maxColumnCount )
    if nextRowNumber >= (maxRowCount - 1) and mapData.voterCount >= maxRowCount * maxColumnCount then
        return x + avatarTotalSize * (maxColumnCount - 1), y + (maxRowCount - 1) * avatarTotalSize, false
    end
    return x + avatarTotalSize * (mapData.voterCount % maxColumnCount), y + nextRowNumber * avatarTotalSize, true
end

function PANEL:setup()
    for _, row in pairs( self.rows ) do
        row:Remove()
    end
    self.rows = {}
    local count = #self.maps
    local margin = 2
    local iconWidth, iconHeight = maxIconSize( self:GetWide(), self:GetTall(), count, 1 )
    iconWidth = iconWidth - margin * 2

    local maxItemsPerRow = math.floor( self:GetWide() / iconWidth )

    local requiredRows = math.ceil( count / maxItemsPerRow )
    for rowNumber = 1, requiredRows do
        local itemsLeft = count - (rowNumber - 1) * maxItemsPerRow
        local itemsInRow = math.min( maxItemsPerRow, itemsLeft )
        local rowWidth = (iconWidth + margin * 2) * itemsInRow

        local row = vgui.Create( "Panel", self )
        table.insert( self.rows, row )
        row:SetSize( rowWidth, iconHeight )
        local extraSpace = math.max( 0, self:GetWide() - rowWidth )

        row:SetPos( extraSpace / 2, iconHeight * (rowNumber - 1) )
        for i = 1, itemsInRow do
            local index = (rowNumber - 1) * maxItemsPerRow + i
            local map = self.maps[index]
            local mapIcon = vgui.Create( "MapVote_MapIcon", row ) --[[@as MapIcon]]
            ---@diagnostic disable-next-line: duplicate-set-field
            mapIcon.DoClick = function()
                self:OnMapClicked( index, map )
            end
            mapIcon:SetMap( map.map )
            mapIcon:SetSize( iconWidth, iconHeight )
            mapIcon:Dock( LEFT )
            mapIcon:DockMargin( margin, margin, margin, margin )
            mapIcon.row = row
            mapIcon.voterCount = 0
            map.panel = mapIcon
        end
    end
end

function PANEL:UpdateRowPositions()
    local count = #self.maps
    local margin = 2
    local iconWidth, iconHeight = maxIconSize( self:GetWide(), self:GetTall(), count, 1 )
    iconWidth = iconWidth - margin * 2

    local maxItemsPerRow = math.floor( self:GetWide() / iconWidth )
    for i, row in ipairs( self.rows ) do
        local rowNumber = i
        local itemsLeft = count - (rowNumber - 1) * maxItemsPerRow
        local itemsInRow = math.min( maxItemsPerRow, itemsLeft )
        local rowWidth = (iconWidth + margin * 2) * itemsInRow

        local extraSpace = math.max( 0, self:GetWide() - rowWidth )

        row:SetPos( extraSpace / 2, iconHeight * (rowNumber - 1) )
    end
end

function PANEL:OnMapClicked( _, _ )
    -- implement
end

function PANEL:GetTotalRowWidth()
    if #self.rows == 0 then return 0 end
    return self.rows[1]:GetWide()
end

function PANEL:GetTotalRowHeight()
    if #self.rows == 0 then return 0 end
    return #self.rows * self.rows[1]:GetTall()
end

function PANEL:Flash( id )
    local data = self:GetMapDataByIndex( id )
    local panel = data.panel
    panel:SetBGColor( MapVote.style.colorPurple )

    timer.Simple( 0, function()
        panel:SetPaintBackgroundEnabled( true )
        surface.PlaySound( "hl1/fvox/blip.wav" )
    end )
    timer.Simple( 0.2, function() panel:SetPaintBackgroundEnabled( false ) end )
    timer.Simple( 0.4, function()
        panel:SetPaintBackgroundEnabled( true )
        surface.PlaySound( "hl1/fvox/blip.wav" )
    end )
    timer.Simple( 0.6, function() panel:SetPaintBackgroundEnabled( false ) end )
    timer.Simple( 0.8, function()
        panel:SetPaintBackgroundEnabled( true )
        surface.PlaySound( "hl1/fvox/blip.wav" )
    end )
    timer.Simple( 1.5, function() panel:SetPaintBackgroundEnabled( false ) end )
end

vgui.Register( "MapVote_Vote", PANEL, "Panel" )
