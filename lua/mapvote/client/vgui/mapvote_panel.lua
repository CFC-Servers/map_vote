---@class MapVote_VoteArea : Panel
local PANEL = {}

---@alias VoteAreaMap {name: string, panel: Panel, voters: Panel[]}
---@alias VoteAreaVoter {identifier: string|Player, mapIndex: number, panel: Panel}

function PANEL:Init()
    self.avatarSize = 50

    ---@type VoteAreaMap[]
    self.maps = {}

    ---@type (Panel|{mapContainer: Panel})[]
    self.rows = {}

    ---@type table<string, VoteAreaVoter>
    self.votes = {}
end

function PANEL:GetMapByIndex( index )
    return self.maps[index]
end

function PANEL:CenterAllRows()
    for _, row in ipairs( self.rows ) do
        row.mapContainer:CenterHorizontal()
    end
end

function PANEL:GetTotalRowWidth()
    if #self.rows == 0 then return 0 end
    return self.rows[1].mapContainer:GetWide()
end

function PANEL:GetTotalRowHeight()
    if #self.rows == 0 then return 0 end
    return #self.rows * self.rows[1]:GetTall()
end

---@param identifier any
---@param mapIndex number
function PANEL:SetVote( identifier, mapIndex )
    local mapData = self.maps[mapIndex]
    if not mapData then
        error( "Invalid map index " .. mapIndex )
        return
    end

    local oldVote = self.votes[identifier]
    local panel
    if oldVote then
        if oldVote.mapIndex == mapIndex then
            return
        end
        local oldMapData = self.maps[oldVote.mapIndex]

        -- Find index in votes for the old map, then reposition all icons after it
        local indexToRemove = nil
        for i, voter in ipairs( oldMapData.voters ) do
            if voter == oldVote.panel then
                indexToRemove = i
                break
            end
        end
        if indexToRemove then
            table.remove( oldMapData.voters, indexToRemove )
        end

        for i = indexToRemove, #oldMapData.voters do
            local voter = oldMapData.voters[i]
            local newX, newY, willOverflow = self:CalculateDesiredAvatarIconPosition( oldMapData, i )
            voter:SetVisible( true )
            voter:MoveTo( newX, newY, 0.2, nil, nil, function( _, pnl )
                pnl:SetVisible( not willOverflow )
            end )
        end

        panel = oldVote.panel
    else
        panel = self:CreateVoterPanel( identifier )
    end

    table.insert( mapData.voters, panel )

    self.votes[identifier] = {
        identifier = identifier,
        mapIndex = mapIndex,
        panel = panel,
    }

    local newX, newY, willOverflow = self:CalculateDesiredAvatarIconPosition( mapData )
    panel:SetVisible( true )
    panel:MoveTo( newX, newY, 0.2, nil, nil, function()
        if willOverflow then
            panel:SetVisible( not willOverflow )
        end
    end )
end

function PANEL:CalculateDesiredAvatarIconPosition( mapData, index )
    if not index then
        index = #mapData.voters
    end
    index = index - 1

    local avatarIconPadding = 1
    local avatarTotalSize = self.avatarSize + avatarIconPadding * 2

    local mapIcon = mapData.panel
    local maxColumnCount = math.floor( mapIcon:GetWide() / avatarTotalSize )
    local maxRowCount = math.floor( (mapIcon:GetTall() - 10) / avatarTotalSize )

    local column = index % maxColumnCount
    local row = math.floor( index / maxColumnCount )

    local x = column * avatarTotalSize + avatarIconPadding
    local y = row * avatarTotalSize + avatarIconPadding

    local rootPosX, rootPosY = self:GetPositionRelativeToSelf( mapIcon )

    return rootPosX + x, rootPosY + y, row >= maxRowCount
end

---@param mapPanel Panel
---@return number, number
---@private
function PANEL:GetPositionRelativeToSelf( mapPanel )
    local screenX, screenY = mapPanel:LocalToScreen( 0, 0 )
    local x, y = self:ScreenToLocal( screenX, screenY )
    return x, y
end

---@param identifier string|Player
---@return Player
---@private
function PANEL:GetPlayerFromIdentifier( identifier )
    if type( identifier ) == "string" then
        return player.GetBySteamID64( identifier )
    elseif type( identifier ) == "Player" then
        return identifier
    end
    return identifier
end

---@param identifier string|Player
---@return Panel
---@private
function PANEL:CreateVoterPanel( identifier )
    local ply = self:GetPlayerFromIdentifier( identifier )

    local iconContainer = vgui.Create( "Panel", self )
    local icon = vgui.Create( "AvatarImage", iconContainer ) --[[@as AvatarImage]]
    icon:SetSize( self.avatarSize, self.avatarSize )
    icon:SetZPos( 1000 )

    iconContainer.ply = ply
    icon:SetPlayer( ply, self.avatarSize )

    iconContainer:SetSize( self.avatarSize + 2, self.avatarSize + 2 )
    icon:SetPos( 2, 2 )

    iconContainer:SetMouseInputEnabled( false )
    icon:SetAlpha( 200 )

    return iconContainer
end

---@param w number
---@param h number
---@param n number
---@return number, number
---@private
function PANEL:maxIconSize( w, h, n )
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

---@param maps string[]
function PANEL:SetMaps( maps )
    self.maps = {}
    for i, map in ipairs( maps ) do
        self.maps[i] = {
            name = map,
            voters = {},
        }
    end

    -- Remove all rows
    for _, row in ipairs( self.rows ) do
        row:Remove()
    end

    -- Remove all voters
    for _, voter in pairs( self.votes ) do
        voter.panel:Remove()
    end
    self.votes = {}

    local maxW, maxH = self:maxIconSize( self:GetWide(), self:GetTall(), #self.maps )
    local rowCount = math.floor( self:GetTall() / maxH )
    local columnCount = math.floor( self:GetWide() / maxW )
    self:CalculateAvatarSize( maxW, maxH )

    local mapIndex = 1
    for i = 1, rowCount do
        local row = self:CreateRow( maxH )
        self.rows[i] = row

        -- create maps in row
        local rowWidth = 0
        for _ = 1, columnCount do
            local currentMapIndex = mapIndex
            local mapName = self.maps[currentMapIndex].name

            local icon = vgui.Create( "MapVote_MapIcon", row.mapContainer )
            icon:SetSize( maxW, maxH )
            icon:Dock( LEFT )
            icon:SetMap( mapName )
            ---@diagnostic disable-next-line: duplicate-set-field
            icon.DoClick = function()
                self:OnMapClicked( currentMapIndex, mapName )
            end

            self.maps[mapIndex].panel = icon
            rowWidth = rowWidth + maxW
            mapIndex = mapIndex + 1
            if mapIndex > #self.maps then
                break
            end
        end

        row:Dock( TOP )
        row:InvalidateParent( true )
        row.mapContainer:SetWide( rowWidth )
        row.mapContainer:CenterHorizontal()
        if mapIndex > #self.maps then
            break
        end
    end
end

function PANEL:CalculateAvatarSize( maxW, maxH )
    local extraSlots = 5
    local plyCount = player.GetCount() + extraSlots
    local newAvatarSize = math.min( maxW, maxH ) / math.ceil( math.sqrt( plyCount ) )
    self.avatarSize = math.max( 20, newAvatarSize )
end

function PANEL:OnMapClicked( index, map )
end

---@return Panel|{mapContainer: Panel}
---@private
function PANEL:CreateRow( iconHeight )
    local row = vgui.Create( "Panel", self )
    row:DockMargin( 0, 0, 0, 2 )
    row:SetTall( iconHeight )
    row:InvalidateParent( true )

    -- we use an inner container so we can center the maps
    local mapContainer = vgui.Create( "Panel", row )
    mapContainer:SetTall( iconHeight )
    row.mapContainer = mapContainer

    return row
end

function PANEL:Flash( id )
    local data = self:GetMapByIndex( id )
    local panel = data.panel
    panel:SetBGColor( MapVote.style.colorPurple )

    timer.Simple( 0, function()
        if not IsValid( panel ) then return end
        panel:SetPaintBackgroundEnabled( true )
        surface.PlaySound( "hl1/fvox/blip.wav" )
    end )
    timer.Simple( 0.2, function()
        if not IsValid( panel ) then return end
        panel:SetPaintBackgroundEnabled( false )
    end )
    timer.Simple( 0.4, function()
        if not IsValid( panel ) then return end
        panel:SetPaintBackgroundEnabled( true )
        surface.PlaySound( "hl1/fvox/blip.wav" )
    end )
    timer.Simple( 0.6, function()
        if not IsValid( panel ) then return end
        panel:SetPaintBackgroundEnabled( false )
    end )
    timer.Simple( 0.8, function()
        if not IsValid( panel ) then return end
        panel:SetPaintBackgroundEnabled( true )
        surface.PlaySound( "hl1/fvox/blip.wav" )
    end )
    timer.Simple( 1.5, function()
        if not IsValid( panel ) then return end
        panel:SetPaintBackgroundEnabled( false )
    end )
end

vgui.Register( "MapVote_VoteArea", PANEL, "Panel" )
