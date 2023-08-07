function MapVote.FinishVote( mapIndex )
    if not IsValid( MapVote.Panel ) then return end
    MapVote.Panel:SetVisible( true )
    MapVote.Panel.voteArea:Flash( mapIndex )
end

function MapVote.CancelVote()
    if IsValid( MapVote.Panel ) then MapVote.Panel:Remove() end
    hook.Run( "MapVote_VoteCancelled" )
end

function MapVote.ChangeVote( ply, mapIndex )
    if not IsValid( ply ) then return end
    if not IsValid( MapVote.Panel ) then return end

    local mapData = MapVote.Panel.voteArea:GetMapDataByIndex( mapIndex )
    MapVote.Panel.voteArea:SetVote( ply, mapData.map )
end

local function apply( items, func )
    for _, item in pairs( items ) do
        func( item )
    end
end
local function hideButton( btn )
    btn:SetVisible( false )
    btn:SetHeight( 0 )
end

local function showButton( btn )
    btn:SetVisible( true )
    btn:SetHeight( 24 )
end

function MapVote.StartVote( maps, endTime )
    MapVote.EndTime = endTime
    if IsValid( MapVote.Panel ) then MapVote.Panel:Remove() end

    local frame = vgui.Create( "MapVote_Frame" ) --[[@as MapVote_Frame]]
    frame:SetSize( ScrW() * 0.8, ScrH() * 0.85 )
    frame:Center()
    frame:MakePopup()
    frame:SetKeyboardInputEnabled( false )
    frame:SetTitle( "" )
    frame:SetHideOnClose( true )

    frame._isVisible = true
    ---@diagnostic disable-next-line: duplicate-set-field
    frame.SetVisible = function( self, v )
        self:OnVisibilityChanged( v )
        if v and not self._isVisible then
            self._isVisible = v
            apply( { self.btnClose, self.btnMaxim, self.btnMinim }, showButton )
            self:DockPadding( 5, 24 + 5, 5, 5 )
            self:MakePopup()
            self:SetKeyboardInputEnabled( false )
            self.voteArea:SetVisible( true )
            self.titleLabel:SetText( "Vote for a new map!" )
            local targetSize = self._originalSize or Vector( ScrW() * 0.8, ScrH() * 0.85 )
            local targetPos = Vector( ScrW() / 2 - targetSize.x / 2, ScrH() / 2 - targetSize.y / 2 )
            MapVote.DoPanelMove( self, targetPos, targetSize, 0.3 )
        elseif not v and self._isVisible then
            self._isVisible = v
            local targetSize = Vector( ScrW() * 0.4, ScrH() * 0.05 )
            local targetPos = Vector( ScrW() / 2 - targetSize.x / 2, 20 )
            self._originalSize = Vector( self:GetSize() )
            MapVote.DoPanelMove( self, targetPos, targetSize, 0.3, function()
                if self._isVisible then return end
                apply( { self.btnClose, self.btnMaxim, self.btnMinim }, hideButton )
                self:DockPadding( 5, 5, 5, 5 )
                self.voteArea:SetVisible( false )
                self:KillFocus()
                self:SetMouseInputEnabled( false )
                self:SetKeyboardInputEnabled( false )
                self.titleLabel:SetText( "Vote for a new map! (F3 to vote)" )
                self.titleLabel:SetWide( 700 )
            end )
        end
    end

    frame.OnVisibilityChanged = function( _, v )
        if v then
            hook.Run( "MapVote_VotePanelOpened" )
        else
            hook.Run( "MapVote_VotePanelClosed" )
        end
    end

    local infoRow = vgui.Create( "Panel", frame ) --[[@as DPanel]]
    infoRow:Dock( TOP )
    infoRow:SetTall( 40 )

    local titleLabel = vgui.Create( "DLabel", infoRow ) --[[@as DLabel]]
    titleLabel:SetColor( MapVote.style.colorTextPrimary )
    titleLabel:SetText( "Vote for a new map!" )
    titleLabel:Dock( LEFT )
    titleLabel:SetWide( 500 )
    titleLabel:DockMargin( 10, 5, 5, 5 )
    titleLabel:SetFont( MapVote.style.mapVoteTitleFont )
    frame.titleLabel = titleLabel
    local countdownLabel = vgui.Create( "DLabel", infoRow ) --[[@as DLabel]]
    countdownLabel:SetColor( MapVote.style.colorTextPrimary )
    countdownLabel:SetText( "00:45" )
    countdownLabel:Dock( RIGHT )
    countdownLabel:SetWide( 80 )
    countdownLabel:DockMargin( 5, 5, 5, 10 )
    countdownLabel:SetFont( MapVote.style.mapVoteTitleFont )
    timer.Create( "MapVoteCountdown", 0.1, 0, function()
        if not IsValid( countdownLabel ) then
            timer.Remove( "MapVoteCountdown" )
            return
        end
        local timeLeft = math.Round( math.Clamp( endTime - CurTime(), 0, math.huge ) )

        countdownLabel:SetText( string.FormattedTime( timeLeft or 0, "%02i:%02i" ) )
    end )
    local voteArea = vgui.Create( "MapVote_Vote", frame ) --[[@as VoteArea]]
    local margin = 10
    voteArea:Dock( FILL )
    voteArea:DockMargin( margin, margin, margin, margin )
    voteArea:SetMaps( maps )
    voteArea:InvalidateLayout( true )
    voteArea:InvalidateParent( true )

    frame:SetTall( voteArea:GetTotalRowHeight() + infoRow:GetTall() + margin * 2 + 34 )
    frame:SetWide( voteArea:GetTotalRowWidth() + margin * 2 + 10 )
    voteArea:InvalidateParent( true )
    frame:Center()
    voteArea:UpdateRowPositions()

    local lastClicked = CurTime()
    ---@diagnostic disable-next-line: duplicate-set-field
    voteArea.OnMapClicked = function( _, index, _ )
        -- TODO this could use the leaky bucket rate limiting the server does
        if CurTime() - lastClicked > 0.4 then
            MapVote.Net.changeVote( index )
        end
    end

    frame.voteArea = voteArea
    MapVote.ThumbDownloader:RequestWorkshopIDs()

    MapVote.Panel = frame

    hook.Run( "MapVote_VoteStarted" )
    hook.Run( "MapVote_VotePanelOpened" )
end

hook.Add( "Tick", "MapVote_RequestState", function()
    hook.Remove( "Tick", "MapVote_RequestState" )
    timer.Simple( 5, function()
        MapVote.Net.requestState()
    end )
end )
