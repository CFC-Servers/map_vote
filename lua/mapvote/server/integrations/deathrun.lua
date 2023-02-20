if GAMEMODE_NAME ~= "deathrun" then return end
hook.Add("MapVote_RTVStart", "MapVote_DeathRunStartVoteAfterRound", function()

    net.Start( "RTV_Delay" )
    net.Broadcast()
    hook.Add( "RoundEnd", "MapvoteDelayed", function() MapVote.Start() end )

    return false
end)
