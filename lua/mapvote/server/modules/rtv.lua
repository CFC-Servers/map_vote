MapVote.RTV = MapVote.RTV or {}
local RTV = MapVote.RTV


-- Removes the ulx votemap command.
hook.Add( "InitPostEntity", "RemoveULXVotemap", function()
    if not ULib or not ulx then return end
    for k, v in pairs( ulx.cmdsByCategory["Voting"] ) do
        if v.cmd == "ulx votemap" then
            ulx.cmdsByCategory["Voting"][k] = nil
        end
    end

    ULib.removeSayCommand( "!votemap" )
end )
RTV.ChatCommandPrefixes = {"!", "/"}
RTV.ChatCommands = {
    ["rtv"] = function(...) RTV.HandleRTVCommand(...) end,
    ["votemap"] = function(...) RTV.HandleRTVCommand(...) end,
    ["mapvote"] = function(...) RTV.HandleRTVCommand(...) end,
    ["unrtv"] = function(...) RTV.HandleUnRTVCommand(...) end,
    ["unvotemap"] = function(...) RTV.HandleUnRTVCommand(...) end,
    ["unmapvote"] = function(...) RTV.HandleUnRTVCommand(...) end,
}

function RTV.SetupChatCommands()
    for _, prefix in ipairs(RTV.ChatCommandPrefixes) do
        for command, func in pairs(RTV.ChatCommands) do
            RTV.ChatCommands[prefix .. command] = func
        end
    end
end
RTV.SetupChatCommands()

hook.Add( "MapVote_ConfigLoaded", "MapVote_RTVInit", function()
    RTV._ActualWait = CurTime() + MapVote.Config.RTVWait
    RTV.PlayerCount = MapVote.Config.RTVPlayerCount or 3
    RTV.PercentPlayersRequired = MapVote.Config.RTVPercentPlayersRequired or 0.66
end)

function RTV.ShouldCountPlayer( ply )
    local result = hook.Run( "MapVote_RTVShouldCountPlayer", ply )
    if result ~= nil then return result end

    return true
end

function RTV.GetPlayerCount()
    local count = 0
    for _, ply in pairs( player.GetHumans() ) do
        if RTV.ShouldCountPlayer( ply ) then
            count = count + 1
        end
    end
    return count
end

function RTV.GetVoteCount()
    local count = 0
    for _, ply in pairs( player.GetHumans() ) do
        if RTV.ShouldCountPlayer( ply ) and ply.RTVVoted then
            count = count + 1
        end
    end
    return count
end

function RTV.ShouldChange()
    if MapVote.IsInProgress then return end
    local plyCount = player.GetCount()
    if plyCount < MapVote.Config.RTVPlayerCount then return end
    local totalVotes = RTV.GetVoteCount()
    local totalPlayers = RTV.GetPlayerCount()
    return totalVotes >= math.Round( totalPlayers * MapVote.Config.RTVPercentPlayersRequired )
end

function RTV.StartIfShouldChange()
    if RTV.ShouldChange() then
        RTV.Start()
    end
end

function RTV.Start()
    if hook.Run( "MapVote_RTVStart" ) == false then return end

    PrintMessage( HUD_PRINTTALK, "The vote has been rocked, map vote imminent" )
    timer.Simple( 4, MapVote.Start )
end

function RTV.AddVote( ply )
    ply.RTVVoted = true
    MsgN( ply:Nick() .. " has voted to change the map." )
    local percentage = math.Round( RTV.GetPlayerCount() * RTV.PercentPlayersRequired )
    PrintMessage( HUD_PRINTTALK, ply:Nick() .. " has voted to change the map. (" .. RTV.GetVoteCount() .. "/" .. percentage .. ")" )
end

hook.Add( "PlayerDisconnected", "Remove RTV", function()
    timer.Simple( 0.1, RTV.StartIfShouldChange )
end )

function RTV.CanVote( ply )
    local plyCount = player.GetCount()

    if MapVote.Config.RTVWait >= CurTime() then
        return false, "You must wait a bit before voting!"
    end

    if GetGlobalBool( "In_Voting" ) then
        return false, "There is currently a vote in progress!"
    end

    if ply.RTVVoted then
        return false, string.format( "You have already voted to change the map! (%s/%s)", RTV.GetVoteCount(), math.Round( RTV.GetPlayerCount() * RTV.PercentPlayersRequired ) )
    end

    if MapVote.IsInProgress then
        return false,
               "There is already a vote in progress"
    end
    if plyCount < MapVote.Config.RTVPlayerCount then
        return false, "You need more players before you can mapvote!"
    end

    return true

end

function RTV.StartVote( ply )
    local can, err = RTV.CanVote( ply )

    if not can then
        ply:PrintMessage( HUD_PRINTTALK, err )
        return
    end

    RTV.AddVote( ply )
    RTV.StartIfShouldChange()
end

concommand.Add( "rtv_start", RTV.StartVote )

hook.Add( "PlayerSay", "RTV Chat Commands", function( ply, text )
    text = string.lower( text )

    local f = RTV.ChatCommands[text]
    if f then
        f( ply )
        return ""
    end
end)

function RTV.HandleRTVCommand( ply )
    RTV.StartVote( ply )
end

function RTV.HandleUnRTVCommand( ply )
    if not ply.RTVVoted then
        ply:PrintMessage( HUD_PRINTTALK, "You have not rocked the vote!" )
        return
    end

    ply.RTVVoted = false
    ply:PrintMessage( HUD_PRINTTALK, "Your vote has been removed!" )
end
