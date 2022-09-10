util.AddNetworkString( "RAM_MapVoteStart" )
util.AddNetworkString( "RAM_MapVoteUpdate" )
util.AddNetworkString( "RAM_MapVoteCancel" )
util.AddNetworkString( "RTV_Delay" )

MapVote.Continued = false

local recentmaps = {}
local playCount = {}

net.Receive(  "RAM_MapVoteUpdate", function(  _, ply )
    if not MapVote.Allow then return end
    if not IsValid( ply ) then return end

    local update_type = net.ReadUInt( 3 )
    if update_type ~= MapVote.UPDATE_VOTE then return end

    local map_id = net.ReadUInt( 32 )
    if not MapVote.CurrentMaps[map_id] then return end

    MapVote.Votes[ply:SteamID()] = map_id

    net.Start( "RAM_MapVoteUpdate" )
        net.WriteUInt( MapVote.UPDATE_VOTE, 3 )
        net.WriteEntity( ply )
        net.WriteUInt( map_id, 32 )
    net.Broadcast()
end )

if file.Exists( "mapvote/recentmaps.txt", "DATA" ) then
    recentmaps = util.JSONToTable( file.Read( "mapvote/recentmaps.txt", "DATA" ) )
else
    recentmaps = {}
end

if file.Exists( "mapvote/playcount.txt", "DATA" ) then
    playCount = util.JSONToTable( file.Read( "mapvote/playcount.txt", "DATA" ) )
else
    playCount = {}
end

function CoolDownDoStuff()
    cooldownnum = MapVote.Config.MapsBeforeRevote or 3

    if #recentmaps == cooldownnum then table.remove( recentmaps ) end

    local curmap = game.GetMap():lower() .. ".bsp"

    if not table.HasValue( recentmaps, curmap ) then
        table.insert( recentmaps, 1, curmap )
    end

    if playCount[curmap] == nil then
        playCount[curmap] = 1
    else
        playCount[curmap] = playCount[curmap] + 1
    end

    file.Write( "mapvote/recentmaps.txt", util.TableToJSON( recentmaps ) )
    file.Write( "mapvote/playcount.txt", util.TableToJSON( playCount ) )
end

local function mapVoteOver( callback )
    MapVote.Allow = false
    local map_results = {}

    for k, v in pairs( MapVote.Votes ) do
        if ( not map_results[v] ) then map_results[v] = 0 end

        for _, v2 in pairs( player.GetAll() ) do
            if ( v2:SteamID() == k ) then
                map_results[v] = map_results[v] + 1
            end
        end

    end

    CoolDownDoStuff()

    local winner = table.GetWinningKey( map_results ) or 1

    net.Start( "RAM_MapVoteUpdate" )
    net.WriteUInt( MapVote.UPDATE_WIN, 3 )

    net.WriteUInt( winner, 32 )
    net.Broadcast()

    local map = MapVote.CurrentMaps[winner]

    local gamemode = nil

    if autoGamemode then
        -- check if map matches a gamemode's map pattern
        for _, gm in pairs( engine.GetGamemodes() ) do
            -- ignore empty patterns
            if gm.maps and gm.maps ~= "" then
                -- patterns are separated by "|"
                for _, pattern in pairs( string.Split( gm.maps, "|" ) ) do
                    if string.match( map, pattern ) then
                        gamemode = gm.name
                        break
                    end
                end
            end
        end
    else
        print( "not enabled" )
    end

    timer.Simple( 4, function()
        if ( hook.Run( "MapVoteChange", map ) ~= false ) then
            if ( callback ) then
                callback( map )
            else
                -- if map requires another gamemode then switch to it
                if ( gamemode and gamemode ~= engine.ActiveGamemode() ) then
                    RunConsoleCommand( "gamemode", gamemode )
                end
                RunConsoleCommand( "changelevel", map )
            end
        end
    end )
end

function MapVote.Start( length, current, limit, prefix, callback )
    current = current or MapVote.Config.AllowCurrentMap or false
    length = length or MapVote.Config.TimeLimit or 28
    limit = limit or MapVote.Config.MapLimit or 24
    cooldown = MapVote.Config.EnableCooldown or MapVote.Config.EnableCooldown == nil and true
    prefix = prefix or MapVote.Config.MapPrefixes
    autoGamemode = autoGamemode or MapVote.Config.AutoGamemode or MapVote.Config.AutoGamemode == nil and true

    local is_expression = false

    if not prefix then
        local info = file.Read( GAMEMODE.Folder .. "/" .. GAMEMODE.FolderName .. ".txt", "GAME" )

        if info then
            info = util.KeyValuesToTable( info )
            prefix = info.maps
        else
            error( "MapVote Prefix can not be loaded from gamemode" )
        end

        is_expression = true
    else
        if prefix and type( prefix ) ~= "table" then prefix = { prefix } end
    end

    local maps = file.Find( "maps/*.bsp", "GAME" )

    local vote_maps = {}
    local play_counts = {}

    local amt = 0

    for _, map in RandomPairs( maps ) do
        local plays = playCount[map]

        if ( plays == nil ) then
            plays = 0
        end

        local isExcludedMap = MapVote.Config.ExcludedMaps[map]
        local isCurrentMap = not current and game.GetMap():lower() .. ".bsp" == map
        local isOnCooldown = table.HasValue( recentmaps, map ) and cooldown

        if not ( isCurrentMap or isOnCooldown or isExcludedMap ) then
            if MapVote.Config.IncludedMaps[map] then
                vote_maps[#vote_maps + 1] = map:sub( 1, -5 )
                play_counts[#play_counts + 1] = plays
                amt = amt + 1
            elseif is_expression then
                if string.find( map, prefix ) then -- This might work ( from gamemode.txt )
                    vote_maps[#vote_maps + 1] = map:sub( 1, -5 )
                    play_counts[#play_counts + 1] = plays
                    amt = amt + 1
                end
            else
                for _, v in pairs( prefix ) do
                    if string.find( map, "^" .. v ) then
                        vote_maps[#vote_maps + 1] = map:sub( 1, -5 )
                        play_counts[#play_counts + 1] = plays
                        amt = amt + 1
                        break
                    end
                end
            end

            if ( limit and amt >= limit ) then break end
        end
    end

    net.Start( "RAM_MapVoteStart" )
    net.WriteUInt( #vote_maps, 32 )

    for i = 1, #vote_maps do
        net.WriteString( vote_maps[i] )
        net.WriteUInt( play_counts[i], 32 )
    end

    net.WriteUInt( length, 32 )
    net.Broadcast()

    MapVote.Allow = true
    MapVote.CurrentMaps = vote_maps
    MapVote.Votes = {}

    timer.Create( "RAM_MapVote_Timer", length, 1, function()
        mapVoteOver( callback )
    end )
end

hook.Add( "Shutdown", "RemoveRecentMaps", function()
    if file.Exists( "mapvote/recentmaps.txt", "DATA" ) then
        file.Delete( "mapvote/recentmaps.txt" )
    end
end )

function MapVote.Cancel()
    RTV.ChangingMaps = false
    if MapVote.Allow then
        MapVote.Allow = false

        net.Start( "RAM_MapVoteCancel" )
        net.Broadcast()

        timer.Remove( "RAM_MapVote" )
    end
end
