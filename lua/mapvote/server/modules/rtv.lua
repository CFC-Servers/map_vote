local RTV = MapVote.RTV or {}
MapVote.RTV = RTV

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
RTV.ChatCommandPrefixes = { "!", "/" }
RTV.ChatCommands = {
    ["rtv"] = function( ... ) RTV.HandleRTVCommand( ... ) end,
    ["votemap"] = function( ... ) RTV.HandleRTVCommand( ... ) end,
    ["mapvote"] = function( ... ) RTV.HandleRTVCommand( ... ) end,
    ["unrtv"] = function( ... ) RTV.HandleUnRTVCommand( ... ) end,
    ["unvotemap"] = function( ... ) RTV.HandleUnRTVCommand( ... ) end,
    ["unmapvote"] = function( ... ) RTV.HandleUnRTVCommand( ... ) end,
}

function RTV.SetupChatCommands()
    for _, prefix in ipairs( RTV.ChatCommandPrefixes ) do
        for command, func in pairs( RTV.ChatCommands ) do
            RTV.ChatCommands[prefix .. command] = func
        end
    end
end

RTV.SetupChatCommands()

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
    if MapVote.state.isInProgress then return end
    local conf = MapVote.GetConfig()
    local plyCount = player.GetCount()
    if plyCount < conf.RTVPlayerCount then return end
    local totalVotes = RTV.GetVoteCount()
    local totalPlayers = RTV.GetPlayerCount()
    if totalPlayers == 0 then return end
    return totalVotes >= math.Round( totalPlayers * conf.RTVPercentPlayersRequired )
end

function RTV.StartIfShouldChange()
    if RTV.ShouldChange() then
        RTV.Start()
    end
end

function RTV.Start()
    if hook.Run( "MapVote_RTVStart" ) == false then return end

    PrintMessage( HUD_PRINTTALK, "The vote has been rocked, map vote imminent" )
    MapVote.Start()
end

function RTV.ResetVotes()
    for _, ply in ipairs( player.GetHumans() ) do
        ply.RTVVoted = nil
    end
end

function RTV.AddVote( ply )
    local conf = MapVote.GetConfig()
    ply.RTVVoted = true
    ply.RTVVotedTime = CurTime()

    MsgN( ply:Nick() .. " has voted to change the map." )
    local percentage = math.Round( RTV.GetPlayerCount() * conf.RTVPercentPlayersRequired )
    PrintMessage( HUD_PRINTTALK,
        ply:Nick() .. " has voted to change the map. (" .. RTV.GetVoteCount() .. "/" .. percentage .. ")" )
end

hook.Add( "PlayerDisconnected", "Remove RTV", function()
    timer.Simple( 0.1, RTV.StartIfShouldChange )
end )

function RTV.CanVote( ply )
    local conf = MapVote.GetConfig()

    local plyCount = #player.GetHumans()

    if conf.RTVWait >= CurTime() then
        return false, "You must wait a bit before voting!"
    end

    if ply.RTVVotedTime and ply.RTVVotedTime + conf.PlyRTVCooldownSeconds >= CurTime() then
        return false, "You must wait a bit before voting again!"
    end

    if GetGlobalBool( "In_Voting" ) then
        return false, "There is currently a vote in progress!"
    end

    if ply.RTVVoted then
        return false,
            string.format( "You have already voted to change the map! (%s/%s)", RTV.GetVoteCount(),
                math.Round( RTV.GetPlayerCount() * conf.RTVPercentPlayersRequired ) )
    end

    if MapVote.state.isInProgress then
        return false,
            "There is already a vote in progress"
    end
    if plyCount < conf.RTVPlayerCount then
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
end )

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
