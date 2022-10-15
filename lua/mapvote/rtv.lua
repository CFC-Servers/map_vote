RTV = RTV or {}

RTV.ChatCommands = {
    ["!rtv"] = RTV.HandleRTVCommand,
    ["/rtv"] = RTV.HandleRTVCommand,
    ["rtv"] = RTV.HandleRTVCommand,

    ["unrtv"] = RTV.HandleUnRTVCommand,
    ["!unrtv"] = RTV.HandleUnRTVCommand,
    ["/unrtv"] = RTV.HandleUnRTVCommand,
}

RTV.Wait = 60 -- The wait time in seconds. This is how long a player has to wait before voting when the map changes. 

RTV._ActualWait = CurTime() + RTV.Wait

RTV.PlayerCount = MapVote.Config.RTVPlayerCount or 3
RTV.PercentPlayersRequired = MapVote.Config.RTVPercentPlayersRequired or 0.66

function RTV.ShouldCountPlayer( ply )
    local result = hook.Run( "RTV_ShouldCountPlayer", ply )
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
    local totalVotes = RTV.GetVoteCount()
    local totalPlayers = RTV.GetPlayerCount()
    return totalVotes >= math.Round( totalPlayers * RTV.PercentPlayersRequired )
end

function RTV.StartIfShouldChange()
    if RTV.ShouldChange() then
        RTV.Start()
    end
end

function RTV.Start()
    if GAMEMODE_NAME == "terrortown" then
        net.Start( "RTV_Delay" )
        net.Broadcast()

        hook.Add( "TTTEndRound", "MapvoteDelayed", function()
            timer.Simple( 20, function()
                MapVote.Start()
            end )
        end )
    elseif GAMEMODE_NAME == "deathrun" then
        net.Start( "RTV_Delay" )
        net.Broadcast()

        hook.Add( "RoundEnd", "MapvoteDelayed",
                 function() MapVote.Start() end )
    else
        PrintMessage( HUD_PRINTTALK, "The vote has been rocked, map vote imminent" )
        timer.Simple( 4, function() MapVote.Start() end )
    end
end

function RTV.AddVote( ply )
    ply.RTVVoted = true
    MsgN( ply:Nick() .. " has voted to Rock the Vote." )
    local percentage = math.Round( RTV.GetPlayerCount() * RTV.PercentPlayersRequired )
    PrintMessage( HUD_PRINTTALK, ply:Nick() .. " has voted to Rock the Vote. (" .. RTV.GetVoteCount() .. "/" .. percentage .. ")" )
end

hook.Add( "PlayerDisconnected", "Remove RTV", function()
    timer.Simple( 0.1, RTV.StartIfShouldChange )
end )

function RTV.CanVote( ply )
    local plyCount = table.Count( player.GetAll() )

    if RTV._ActualWait >= CurTime() then
        return false, "You must wait a bit before voting!"
    end

    if GetGlobalBool( "In_Voting" ) then
        return false, "There is currently a vote in progress!"
    end

    if ply.RTVVoted then
        return false, string.format( "You have already voted to Rock the Vote! (%s/%s)", RTV.GetVoteCount(), math.Round( RTV.GetPlayerCount() * RTV.PercentPlayersRequired ) )
    end

    if MapVote.IsInProgress then
        return false,
               "There is already a vote in progress"
    end
    if plyCount < RTV.PlayerCount then
        return false, "You need more players before you can rock the vote!"
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
    text = string.lower(text)

    local f = RTV.ChatCommands[text]
    if f then
        cmd( ply )
        return ""
    end
)
function RTV.HandleRTVCommand( ply )
    RTV.StartVote( ply )
end

function RTV.HandleUnRTVCommand( ply )
    if not ply.RTVVoted then
        ply:PrintMessage( HUD_PRINTTALK, "You have rocked the vote!" )
        return
    end

    ply.RTVVoted = false
    ply:PrintMessage( HUD_PRINTTALK, "Your vote has been removed!" )
end