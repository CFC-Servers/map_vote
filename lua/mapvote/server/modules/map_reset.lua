local resetMapTimerName = "CFC_MapVote_ResetMap"
local function checkMapReset()
    local count = MapVote.RTV.GetPlayerCount()
    if count < MapVote.Config.MinimumCount then
        local map = MapVote.Config.DefaultMap
        timer.Create(resetMapTimerName, 5*60, 1, function() 
            RunConsoleCommand( "changelevel", map )
        end)
    else
        if timer.Exists(resetMapTimerName) then
            timer.Remove(resetMapTimerName)
        end
    end
end
-- TODO timer.Create("CFC_MapVote_CheckResetMap", 60, 0, checkMapReset)