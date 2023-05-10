hook.Add( "MapVote_VoteStarted", "MapVote_DisableDCInterface", function()
    hook.Add( "CFC_DisconnectInterface_ShouldShowInterface", "MapVote_DisableDisconnectInterface", function()
        return false
    end )
end )

hook.Add( "MapVote_VoteCancelled", "MapVote_EnableDCInterface", function()
    hook.Remove( "CFC_DisconnectInterface_ShouldShowInterface", "MapVote_DisableDisconnectInterface" )
end )

