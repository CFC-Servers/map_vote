function MapVote.FinishVote( mapIndex )
    if not IsValid( MapVote.Panel ) then return end
    MapVote.Panel:SetMinimized( false )
    MapVote.Panel:SetVisible( true )
    MapVote.Panel.voteArea:Flash( mapIndex )
end

function MapVote.CancelVote()
    if IsValid( MapVote.Panel ) then MapVote.Panel:Remove() end
    hook.Run( "MapVote_VoteCancelled" )
end

---@param ply Player
---@param mapIndex number
---@param voteMult number
function MapVote.ChangeVote( ply, mapIndex, voteMult )
    if not IsValid( ply ) then return end
    if not IsValid( MapVote.Panel ) then return end

    ---@type string|Player
    local identifier = ply:SteamID64()
    if ply:IsBot() then
        -- dont use steamid object for bots to allow testing UI locally
        identifier = ply
    end

    MapVote.Panel.voteArea:SetVote( identifier, mapIndex, voteMult )
end

function MapVote.StartVote( maps, endTime )
    MapVote.EndTime = endTime
    if IsValid( MapVote.Panel ) then MapVote.Panel:Remove() end

    local frame = vgui.Create( "MapVote_VoteFrame" )
    frame:SetSize( ScrW() * 0.8, ScrH() * 0.85 )
    frame:Center()
    frame:MakePopup()
    frame:SetKeyboardInputEnabled( false )
    frame:SetTitle( "" )
    frame:SetHideOnClose( true )

    ---@diagnostic disable-next-line: duplicate-set-field
    frame.OnMinimizedChangeStart = function( self, v )
        if v then return end
        self.voteArea:SetVisible( true )
        self.titleLabel:SetText( "Vote for a new map!" )

        hook.Run( "MapVote_VotePanelOpened" )
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    frame.OnMinimizedChangeFinish = function( self, v )
        if not v then return end
        self.voteArea:SetVisible( false )
        self.titleLabel:SetText( "Vote for a new map! (F3 to vote)" )
        self.titleLabel:SetWide( 700 )

        hook.Run( "MapVote_VotePanelClosed" )
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
        local timeLeft = math.ceil( math.Clamp( endTime - CurTime(), 0, math.huge ) )

        countdownLabel:SetText( string.FormattedTime( timeLeft or 0, "%02i:%02i" ) )
    end )
    local voteArea = vgui.Create( "MapVote_VoteArea", frame )
    local margin = 10
    voteArea:Dock( FILL )
    voteArea:DockMargin( margin, margin, margin, margin )
    voteArea:InvalidateLayout( true )
    voteArea:InvalidateParent( true )
    voteArea:SetMaps( maps )

    frame:SetTall( voteArea:GetTotalRowHeight() + infoRow:GetTall() + margin * 3 + 20 )
    frame:SetWide( voteArea:GetTotalRowWidth() + margin * 2 + 10 )
    voteArea:InvalidateLayout( true )
    frame:Center()

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

hook.Add( "InitPostEntity", "MapVote_RequestState", function()
    timer.Simple( 5, function()
        MapVote.Net.requestState()
    end )
end )

gameevent.Listen( "player_disconnect" )
hook.Add( "player_disconnect", "MapVote_RemoveVote", function( data )
    if not IsValid( MapVote.Panel ) then return end

    if data.networkid == "BOT" then
        MapVote.Panel.voteArea:RemoveInvalidVotes()
    else
        MapVote.Panel.voteArea:RemoveVote( data.networkid )
    end
end )
