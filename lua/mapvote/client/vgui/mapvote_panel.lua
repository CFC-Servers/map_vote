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

    self.avatarIconPadding = 1
end

function PANEL:GetMapByIndex( index )
    return self.maps[index]
end

function PANEL:PerformLayout()
    for _, row in ipairs( self.rows ) do
        row.mapContainer:CenterHorizontal()
    end

    -- This is expensive, but must be done so avatar positions dont get misaligned when parent panel is being minimized and resized
    for _, map in ipairs( self.maps ) do
        for i, voter in ipairs( map.voters ) do
            if not voter.inAnimation then
                local newX, newY, willOverflow = self:CalculateDesiredAvatarIconPosition( map, i )
                voter:SetPos( newX, newY )
                voter:SetVisible( not willOverflow )
            end
        end
    end
end

---@return number
function PANEL:GetTotalRowWidth()
    if #self.rows == 0 then return 0 end
    return self.rows[1].mapContainer:GetWide()
end

---@return number
function PANEL:GetTotalRowHeight()
    if #self.rows == 0 then return 0 end
    return #self.rows * self.rows[1]:GetTall()
end

function PANEL:RemoveInvalidVotes()
    for identifier, vote in pairs( self.votes ) do
        local invalidPlayer = (type( identifier ) == "Player") and not IsValid( identifier )
        if not identifier or invalidPlayer then
            self:removeVote( vote )
            self.votes[identifier] = nil
        end
    end
end

function PANEL:RemoveVote( identifier )
    local vote = self.votes[identifier]
    if not vote then return end

    self:removeVote( vote )
    self.votes[identifier] = nil
end

function PANEL:removeVote( oldVote, removePanel )
    if removePanel == nil then
        removePanel = true
    end
    local mapData = self.maps[oldVote.mapIndex]

    -- Find index in votes for the old map, then reposition all icons after it
    local indexToRemove = nil
    for i, voter in ipairs( mapData.voters ) do
        if voter == oldVote.panel then
            indexToRemove = i
            break
        end
    end
    if indexToRemove then
        table.remove( mapData.voters, indexToRemove )
    else
        ErrorNoHalt( "No index to remove??" )
        return
    end

    for i = indexToRemove, #mapData.voters do
        local voter = mapData.voters[i]
        local newX, newY, willOverflow = self:CalculateDesiredAvatarIconPosition( mapData, i )
        voter:SetVisible( true )
        voter.inAnimation = true
        voter:MoveTo( newX, newY, 0.3, nil, 1, function( _, pnl )
            pnl:SetVisible( not willOverflow )
            pnl.inAnimation = false
        end )
    end

    if removePanel then
        oldVote.panel:Remove()
    end
end

---@param identifier any
---@param mapIndex number
function PANEL:SetVote( identifier, mapIndex, voteMult )
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
        self:removeVote( oldVote, false )
        panel = oldVote.panel
    else
        panel = self:CreateVoterPanel( identifier, voteMult )
    end

    table.insert( mapData.voters, panel )

    self.votes[identifier] = {
        identifier = identifier,
        mapIndex = mapIndex,
        panel = panel,
    }

    local newX, newY, willOverflow = self:CalculateDesiredAvatarIconPosition( mapData )
    panel:SetVisible( true )
    panel.inAnimation = true
    panel:MoveTo( newX, newY, 0.3, nil, 1, function( _, pnl )
        pnl:SetVisible( not willOverflow )
        pnl.inAnimation = false
    end )
end

---@param mapData VoteAreaMap
---@param index number|nil
---@return number, number, boolean
function PANEL:CalculateDesiredAvatarIconPosition( mapData, index )
    if not index then
        index = #mapData.voters
    end
    index = index - 1

    local avatarIconPadding = self.avatarIconPadding
    local avatarTotalSize = self.avatarSize + avatarIconPadding * 2

    local mapIcon = mapData.panel
    local maxColumnCount = math.floor( mapIcon:GetWide() / avatarTotalSize )
    local maxRowCount = math.floor( (mapIcon:GetTall() - 20) / avatarTotalSize )

    local column = index % maxColumnCount
    local row = math.floor( index / maxColumnCount )

    local x = column * avatarTotalSize + avatarIconPadding
    local y = row * avatarTotalSize + avatarIconPadding

    local rootPosX, rootPosY = self:GetPositionRelativeToSelf( mapIcon )

    if MapVote.style.bottomUpIconFilling then
        rootPosX = rootPosX + (mapIcon:GetWide() - avatarTotalSize - 2 * avatarIconPadding)
        rootPosY = rootPosY + (mapIcon:GetTall() - avatarTotalSize - 2 * avatarIconPadding)
        return rootPosX - x, rootPosY - y, row >= maxRowCount
    end
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
---@return Player|nil
---@private
function PANEL:GetPlayerFromIdentifier( identifier )
    if type( identifier ) == "string" then
        return player.GetBySteamID64( identifier )
    elseif type( identifier ) == "Player" then
        return identifier
    end
    return nil
end

local createdFonts = {}

local function CreateMultFont( size )
    size = math.max( 12, math.ceil( size * 0.4 ) )
    local name = "MapVote_Multiplier" .. size
    if createdFonts[size] then
        return name
    end

    surface.CreateFont( name, {
        font = "Arial",
        size = size,
        weight = 600,
        antialias = true,
        shadow = false
    } )

    createdFonts[size] = true

    return name
end

---@param identifier string|Player
---@return Panel
---@private
function PANEL:CreateVoterPanel( identifier, voteMult )
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

    if voteMult > 1 then
        local fontName = CreateMultFont( self.avatarSize )
        icon.PaintOver = function()
            draw.SimpleTextOutlined( voteMult .. "x", fontName, 2, 2, MapVote.style.colorTextPrimary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, MapVote.style.colorPrimaryBG )
        end
    end

    return iconContainer
end

-- addapted from https://math.stackexchange.com/questions/466198/algorithm-to-get-the-maximum-size-of-n-squares-that-fit-into-a-rectangle-with-a
---@param x number
---@param y number
---@param n number
---@return number, number
---@private
function PANEL:maxIconSize( x, y, n )
    local px = math.ceil( math.sqrt( n * x / y ) )
    local sx, sy

    if math.floor( px * y / x ) * px < n then
        sx = y / math.ceil( px * y / x )
    else
        sx = x / px
    end

    local py = math.ceil( math.sqrt( n * y / x ) )

    if math.floor( py * x / y ) * py < n then
        sy = x / math.ceil( x * py / y )
    else
        sy = y / py
    end

    local v = math.max( sx, sy )

    return v, v
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
    local columnCount = math.ceil( #self.maps / rowCount )

    self:CalculateAvatarSize( maxW, maxH )

    assert( rowCount * columnCount >= #self.maps, string.format( "Not enough space to display all maps, rowCount: %d, columnCount: %d, maps: %d", rowCount, columnCount, #self.maps ) )

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
            icon:DockMargin( 2, 2, 2, 2 )
            ---@diagnostic disable-next-line: duplicate-set-field
            icon.DoClick = function()
                self:OnMapClicked( currentMapIndex, mapName )
            end

            self.maps[mapIndex].panel = icon
            rowWidth = rowWidth + maxW + 4
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

function PANEL:CalculateAvatarSize( maxW, _maxH )
    -- leave space for 0 joins mid map vote
    local avatarIconPadding = self.avatarIconPadding
    local plyCount = math.max( player.GetCount(), 2 )

    -- add an extra row for title area
    local rowCount = math.ceil( math.sqrt( plyCount ) ) + 1

    local availableSpace = maxW - (avatarIconPadding * 2) * rowCount
    local newAvatarSize = math.ceil( availableSpace / rowCount ) - avatarIconPadding * 2
    self.avatarSize = newAvatarSize
end

---@diagnostic disable-next-line: unused-local
function PANEL:OnMapClicked( _index, _map )
end

---@return Panel|{mapContainer: Panel}
---@private
function PANEL:CreateRow( iconHeight )
    local row = vgui.Create( "Panel", self )
    row:DockMargin( 0, 0, 0, 0 )
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
