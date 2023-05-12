local function maxIconSize( w, h, n, iconAspectRatio )
    local aspectRatio = w / h
    local rows, columns

    if aspectRatio > 1 then
        columns = math.ceil( math.sqrt( n * aspectRatio ) )
        rows = math.ceil( math.sqrt( n / aspectRatio ) )
    else
        rows = math.ceil( math.sqrt( n * aspectRatio ) )
        columns = math.ceil( math.sqrt( n / aspectRatio ) )
    end

    while rows * columns < n do
        if rows < columns then
            rows = rows + 1
        else
            columns = columns + 1
        end
    end

    local iconWidth = w / columns
    local iconHeight = h / rows

    if iconAspectRatio > 1 then
        iconHeight = iconWidth / iconAspectRatio
    else
        iconWidth = iconHeight * iconAspectRatio
    end

    return iconWidth, iconHeight
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
            voterCount = 0,
            panel = nil,
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

    if self.votes[ply] then
        local oldMapName = self.votes[ply].mapName
        local oldMapData = self:GetMapData( oldMapName )

        oldMapData.voterCount = oldMapData.voterCount - 1

        iconContainer = self.votes[ply].panel
    else
        iconContainer = self:CreateVoterPanel( ply, mapName )
    end

    local x, y = self:calculateDesiredAvatarIconPosition( mapData )

    -- the docs are wrong this is fine
    ---@diagnostic disable-next-line: missing-parameter
    iconContainer:MoveTo( x, y, 0.2 )

    mapData.voterCount = mapData.voterCount + 1

    self.votes[ply] = {
        mapName = mapName,
        ply = ply,
        panel = iconContainer
    }
end

function PANEL:CreateVoterPanel( ply, map )
    local iconContainer = vgui.Create( "Panel", self )
    local icon = vgui.Create( "AvatarImage", iconContainer ) --[[@as AvatarImage]]
    icon:SetSize( 30, 30 )
    icon:SetZPos( 1000 )

    iconContainer.ply = ply
    icon:SetPlayer( ply, 32 )

    iconContainer:SetSize( 30, 30 )
    icon:SetPos( 4, 4 )

    iconContainer.Paint = function()
        if iconContainer.img then
            surface.SetMaterial( iconContainer.img )
            surface.SetDrawColor( Color( 255, 255, 255 ) )
            surface.DrawTexturedRect( 2, 2, 16, 16 )
        end
    end

    iconContainer:SetMouseInputEnabled( false )
    iconContainer:SetAlpha( 255 )

    return iconContainer
end

function PANEL:calculateDesiredAvatarIconPosition( mapData )
    local avatarIconSize = 50
    local avatarIconPadding = 1
    local avatarTotalSize = avatarIconSize + avatarIconPadding * 2

    local mapIcon = mapData.panel
    local maxColumnCount = math.floor( mapIcon:GetWide() / avatarTotalSize )

    -- calulate position of mapIcon relative to main vote area panel
    local rowX, rowY = mapIcon.row:GetPos()
    local iconX, iconY = mapIcon:GetPos()
    local x, y = rowX + iconX, rowY + iconY

    local nextRowNumber = math.floor( mapData.voterCount / maxColumnCount )

    return x + avatarTotalSize * (mapData.voterCount % maxColumnCount), y + nextRowNumber * avatarTotalSize
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
    timer.Simple( 0.0, function()
        panel:SetBGColor( MapVote.style.colorPurple )
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
    timer.Simple( 1.0, function()
        panel:SetPaintBackgroundEnabled( true )
    end )
    timer.Simple( 1.5, function() panel:SetPaintBackgroundEnabled( false ) end )
end

vgui.Register( "MapVote_Vote", PANEL, "Panel" )
