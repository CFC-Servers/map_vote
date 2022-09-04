RTV = RTV or {}

RTV.ChatCommands = {"!rtv", "/rtv", "rtv"}

RTV.Wait = 60 -- The wait time in seconds. This is how long a player has to wait before voting when the map changes. 

RTV._ActualWait = CurTime() + RTV.Wait

RTV.PlayerCount = MapVote.Config.RTVPlayerCount or 3
RTV.PercentPlayersRequired = MapVote.Config.RTVPercentPlayersRequired or 0.66

function RTV.ShouldCountPlayer(ply)
    local result = hook.Run("RTV_ShouldCountPlayer", ply)
    if result ~= nil then return result end

    return true
end

function RTV.GetPlayerCount()
    local count = 0
    for _, ply in pairs(player.GetHumans()) do
        if RTV.ShouldCountPlayer(ply) then
            count = count + 1
        end
    end
    return count
end

function RTV.GetVoteCount()
    local count = 0
    for _, ply in pairs(player.GetHumans()) do
        if RTV.ShouldCountPlayer(ply) and ply.RTVVoted then
            count = count + 1
        end
    end
    return count
end

function RTV.ShouldChange()
    local totalVotes = RTV.GetVoteCount()
    local totalPlayers = RTV.GetPlayerCount()
    return totalVotes > math.Round(totalPlayers * RTV.PercentPlayersRequired)
end

function RTV.StartIfShouldChange()
    if RTV.ShouldChange() then
        MapVote.Start()
    end
end

function RTV.Start()
    RTV.ChangingMaps = true
    if GAMEMODE_NAME == "terrortown" then
        net.Start("RTV_Delay")
        net.Broadcast()

        hook.Add("TTTEndRound", "MapvoteDelayed", function() 
            timer.Simple(20, function()
                MapVote.Start(nil, nil, nil, nil) 
            end)
        end)
    elseif GAMEMODE_NAME == "deathrun" then
        net.Start("RTV_Delay")
        net.Broadcast()

        hook.Add("RoundEnd", "MapvoteDelayed",
                 function() MapVote.Start(nil, nil, nil, nil) end)
    else
        PrintMessage(HUD_PRINTTALK,
                     "The vote has been rocked, map vote imminent")
        timer.Simple(4, function() MapVote.Start(nil, nil, nil, nil) end)
    end
end

function RTV.AddVote(ply)
    ply.RTVVoted = true
    MsgN(ply:Nick() .. " has voted to Rock the Vote.")
    PrintMessage(HUD_PRINTTALK,
                    ply:Nick() .. " has voted to Rock the Vote. (" ..
                        RTV.GetVoteCount() .. "/" ..
                        math.Round(RTV.GetPlayerCount() * RTV.PercentPlayersRequired) .. ")")
end

hook.Add("PlayerDisconnected", "Remove RTV", function(ply)
    timer.Simple(0.1, RTV.StartIfShouldChange)
end)

function RTV.CanVote(ply)
    local plyCount = table.Count(player.GetAll())

    if RTV._ActualWait >= CurTime() then
        return false, "You must wait a bit before voting!"
    end

    if GetGlobalBool("In_Voting") then
        return false, "There is currently a vote in progress!"
    end

    if ply.RTVVoted then
        return false, string.format("You have already voted to Rock the Vote! (%s/%s)", RTV.GetVoteCount(), RTV.GetPlayerCount())
    end

    if RTV.ChangingMaps then
        return false,
               "There has already been a vote, the map is going to change!"
    end
    if plyCount < RTV.PlayerCount then
        return false, "You need more players before you can rock the vote!"
    end

    return true

end

function RTV.StartVote(ply)

    local can, err = RTV.CanVote(ply)

    if not can then
        ply:PrintMessage(HUD_PRINTTALK, err)
        return
    end

    RTV.AddVote(ply)
    RTV.StartIfShouldChange()
end

concommand.Add("rtv_start", RTV.StartVote)

hook.Add("PlayerSay", "RTV Chat Commands", function(ply, text)

    if table.HasValue(RTV.ChatCommands, string.lower(text)) then
        RTV.StartVote(ply)
        return ""
    end

end)
