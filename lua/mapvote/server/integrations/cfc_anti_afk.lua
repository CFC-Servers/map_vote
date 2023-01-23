hook.Add( "MapVote_RTVShouldCountPlayer", "CFC_AntiAFK_RTVCanPlayerVote", function( ply )
    local isAFK = ply:GetNWBool( "CFC_AntiAFK_IsAFK" )
    if isAFK then return false end
end )
