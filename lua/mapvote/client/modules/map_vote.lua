function MapVote.OpenPanel( maps )
    local frame = vgui.Create( "MapVote_Frame" ) --[[@as DFrame]]
    frame:SetSize( ScrW() * 0.8, ScrH() * 0.85 )
    frame:Center()
    frame:MakePopup()
    frame:SetTitle( "" )

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
    voteArea.OnMapClicked = function( self, index, _ )
        net.WriteUInt( index, 32 )
        net.SendToServer()
    end

    frame.voteArea = voteArea
    MapVote.ThumbDownloader:RequestWorkshopIDs()
    return frame
end
