if engine.ActiveGamemode() ~= "terrortown" then return end
function CheckForMapSwitch() -- TODO see if this can be improved
    -- Check for mapswitch
    local rounds_left = math.max( 0, GetGlobalInt( "ttt_rounds_left", 6 ) - 1 )
    SetGlobalInt( "ttt_rounds_left", rounds_left )

    local time_left = math.max( 0, ( GetConVar( "ttt_time_limit_minutes" ):GetInt() * 60 ) - CurTime() )
    local switchmap = false
    local nextmap = string.upper( game.GetMapNext() )

    if rounds_left <= 0 then
        LANG.Msg( "limit_round", { mapname = nextmap } )
        switchmap = true
    elseif time_left <= 0 then
        LANG.Msg( "limit_time", { mapname = nextmap } )
        switchmap = true
    end
    if switchmap then
        hook.Add( "TTTDelayRoundStartForVote", "MapVote_DelayRoundStart", function()
            MuteForRestart( false )
            return true
        end )
        timer.Simple( 20, function()
            MapVote.Start()
        end )
    end
end

hook.Add("MapVote_RTVStart", "MapVote_TTTStartVoteAfterRound", function()
    net.Start( "RTV_Delay" )
    net.Broadcast()

    hook.Add( "TTTEndRound", "MapvoteDelayed", function()
        timer.Simple( 20, function()
            MapVote.Start()
        end )
    end )
    return false
end)