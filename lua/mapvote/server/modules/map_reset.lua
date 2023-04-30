local resetMapTimerName = "MapVote_ResetMap"

local function checkMapReset()
    local count = MapVote.RTV.GetPlayerCount()
    local conf = MapVote.GetConfig()

    if count < conf.MinimumPlayersBeforeReset then
        local map = conf.DefaultMap
        timer.Create( resetMapTimerName, 5 * 60, 1, function()
            RunConsoleCommand( "changelevel", map )
        end )
    else
        timer.Remove( resetMapTimerName )
    end
end

hook.Add( "MapVote_Loaded", "MapVote_StartReset", function()
    local conf = MapVote.GetConfig()
    if conf.MinimumPlayersBeforeReset <= 0 then return end
    timer.Create( "MapVote_CheckResetMap", 60, 0, checkMapReset )
end )

