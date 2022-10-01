util.AddNetworkString( "RAM_MapVoteStart" )
util.AddNetworkString( "RAM_MapVoteUpdate" )
util.AddNetworkString( "RAM_MapVoteCancel" )
util.AddNetworkString( "RTV_Delay" )

MapVote.Continued = false

local recentmaps = {}
local playCount = {}

net.Receive(  "RAM_MapVoteUpdate", function(  _, ply )
    if not MapVote.IsInProgress then return end
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

local function CoolDownDoStuff()
    local cooldownnum = MapVote.Config.MapsBeforeRevote or 3

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

local function mapVoteOver( autoGamemode, callback )
    MapVote.IsInProgress = false
    local results = {}

    for k, v in pairs( MapVote.Votes ) do
        if not results[v] then results[v] = 0 end

        if player.GetBySteamID( k ) then
            results[v] = results[v] + 1
        end
    end

    CoolDownDoStuff()

    local winner = table.GetWinningKey( results ) or 1

    net.Start( "RAM_MapVoteUpdate" )
    net.WriteUInt( MapVote.UPDATE_WIN, 3 )

    net.WriteUInt( winner, 32 )
    net.Broadcast()

    local map = MapVote.CurrentMaps[winner]

    timer.Simple( 4, function()
        if hook.Run("MapVoteChange", map) == false then return end
        if callback then
            callback( map )
        end
        
        RunConsoleCommand( "changelevel", map )
    end )
end

-- returns prefix, isExpression
function MapVote.GetMapPrefix() 
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
end

local function isMapAllowed(m)
    local conf = MapVote.Config
    local prefixes = conf.MapPrefixes
    if prefixes and type(prefixes) == "string" then -- This should be done at configuration step
        prefixes = { prefixes }
    end

    if not MapVote.AllowCurrentMap and m == game.GetMap() then return false end -- dont allow current map in vote
    if MapVote.Config.EnableCooldown == true and table.HasValue( recentmaps, m ) then return false end -- dont allow recent maps in vote
    if MapVote.ExcludedMaps[m] then return false end -- dont allow excluded maps in vote
    
    if not MapVote.Config.IncludedMaps[m] then return true end -- skip prefix check if map is in included maps

    for _, v in pairs(prefixes) do
        if string.find( m, "^" .. v ) then
            return true
        end
    end
    return false
end

function MapVote.Start( length, callback )
    length = length or MapVote.Config.TimeLimit or 28

    local maps = file.Find( "maps/*.bsp", "GAME" )
    
    local mapsInVote = {}
    local mapsInVotePlayCounts = {}

    for _, map in RandomPairs( maps ) do
        local plays = playCount[map]
        plays = plays or 0

        if isMapAllowed(map) then
            table.insert( mapsInVote, map:sub( 1, -5))
            table.insert( mapsInVotePlayCounts, plays )

            if #mapsInVote >= MapVote.Config.MapLimit then break end
        end
    end

    net.Start( "RAM_MapVoteStart" )
    net.WriteUInt( #mapsInVote, 32 )

    for i = 1, #mapsInVote do
        net.WriteString( mapsInVote[i] )
        net.WriteUInt( mapsInVotePlayCounts[i], 32 )
    end

    net.WriteUInt( length, 32 )
    net.Broadcast()

    MapVote.IsInProgress = true
    MapVote.CurrentMaps = mapsInVote
    MapVote.Votes = {}

    timer.Create( "RAM_MapVote", length, 1, function()
        mapVoteOver( autoGamemode, callback )
    end )
end

hook.Add( "Shutdown", "RemoveRecentMaps", function()
    if file.Exists( "mapvote/recentmaps.txt", "DATA" ) then
        file.Delete( "mapvote/recentmaps.txt" )
    end
end )

function MapVote.Cancel()
    if MapVote.IsInProgress then
        MapVote.IsInProgress = false
        net.Start( "RAM_MapVoteCancel" )
        net.Broadcast()

        timer.Remove( "RAM_MapVote" )
    end
end
