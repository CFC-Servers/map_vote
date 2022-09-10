hook.Add( "RTV_ShouldCountPlayer", "CFC_AntiAFK_RTVCanPlayerVote", function( ply )
    local isAFK = ply:GetNWBool( "CFC_AntiAFK_IsAFK" )
    if isAFK then return false end
end )
