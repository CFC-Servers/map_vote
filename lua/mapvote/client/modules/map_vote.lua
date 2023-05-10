function MapVote.OpenPanel( maps, endTime )
    local frame = vgui.Create( "MapVote_Frame" ) --[[@as MapVote_Frame]]
    frame:SetSize( ScrW() * 0.8, ScrH() * 0.85 )
    frame:Center()
    frame:MakePopup()
    frame:SetTitle( "" )
    frame:SetHideOnClose( true )

    local infoRow = vgui.Create( "Panel", frame ) --[[@as DPanel]]
    infoRow:Dock( TOP )
    infoRow:SetTall( 40 )

    local titleLabel = vgui.Create( "DLabel", infoRow ) --[[@as DLabel]]
    titleLabel:SetColor( MapVote.style.colorTextPrimary )
    titleLabel:SetText( "Vote for a new map!" )
    titleLabel:Dock( LEFT )
    titleLabel:SetWide( 500 )
    titleLabel:DockMargin( 5, 5, 5, 5 )
    titleLabel:SetFont( MapVote.style.mapVoteTitleFont )

    local countdownLabel = vgui.Create( "DLabel", infoRow ) --[[@as DLabel]]
    countdownLabel:SetColor( MapVote.style.colorTextPrimary )
    countdownLabel:SetText( "00:45" )
    countdownLabel:Dock( RIGHT )
    countdownLabel:SetWide( 80 )
    countdownLabel:DockMargin( 5, 5, 5, 5 )
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
    voteArea:Dock( FILL )
    voteArea:DockMargin( 5, 5, 5, 5 )
    voteArea:SetMaps( maps )
    voteArea:InvalidateLayout( true )
    voteArea:InvalidateParent( true )
    local height = voteArea:GetTotalRowHeight() + 50
    if height < frame:GetTall() then
        frame:SetSize( frame:GetWide(), height )
    end


    ---@diagnostic disable-next-line: duplicate-set-field
    voteArea.OnMapClicked = function( _, index, _ )
        net.Start( "MapVote_ChangeVote" )
        net.WriteUInt( index, 32 )
        net.SendToServer()
    end

    frame.voteArea = voteArea
    MapVote.ThumbDownloader:RequestWorkshopIDs()
    return frame
end
