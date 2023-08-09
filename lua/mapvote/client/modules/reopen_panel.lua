hook.Add( "PlayerButtonDown", "MapVote_ReopenMapvote", function( _, button )
    if button ~= KEY_F3 then return end
    if not IsValid( MapVote.Panel ) then return end
    MapVote.Panel:SetVisible( true )
    MapVote.Panel:SetMinimized( false )
end )
