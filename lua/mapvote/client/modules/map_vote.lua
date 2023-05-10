function MapVote.OpenPanel( maps, endTime )
    local frame = vgui.Create( "MapVote_Frame" ) --[[@as DFrame]]
    frame:SetSize( ScrW() * 0.8, ScrH() * 0.85 )
    frame:Center()
    frame:MakePopup()
    frame:SetTitle( "" )

    local infoRow = vgui.Create( "Panel", frame ) --[[@as DPanel]]
    infoRow:Dock( TOP )
    infoRow:SetTall( 50 )

    local label = vgui.Create( "DLabel", infoRow ) --[[@as DLabel]]
    label:SetColor( MapVote.style.colorTextPrimary )
    label:SetText( "Vote for a new map!" )
    label:Dock( LEFT )
    label:SetWide( 500 )
    label:DockMargin( 5, 5, 5, 5 )
    label:SetFont( MapVote.style.mapVoteTitleFont )

    local label = vgui.Create( "DLabel", infoRow ) --[[@as DLabel]]
    label:SetColor( MapVote.style.colorTextPrimary )
    label:SetText( "00:45" )
    label:Dock( RIGHT )
    label:SetWide( 80 )
    label:DockMargin( 5, 5, 5, 5 )
    label:SetFont( MapVote.style.mapVoteTitleFont )
    timer.Create( "MapVoteCountdown", 0.1, 0, function()
        if not IsValid( label ) then
            timer.Remove( "MapVoteCountdown" )
            return
        end
        local timeLeft = math.Round( math.Clamp( endTime - CurTime(), 0, math.huge ) )

        label:SetText( string.FormattedTime( timeLeft or 0, "%02i:%02i" ) )
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
