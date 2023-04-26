function MapVote.GetMapPrefixesFromGamemode()
    local gamemode = engine.ActiveGamemode()
    local info = file.Read( string.format( "gamemodes/%s/%s.txt", gamemode, gamemode ), "GAME" )

    if not info then return end

    local decoded = util.KeyValuesToTable( info )
    if not decoded.maps then return end

    -- gamemodes like sandbox have a pattern ^gm_|^gmod_|^phys_ this is not a valid lua pattern
    -- so we split the string on |, this will not be reliable but its easier than implementing regex in lua
    local splitString = string.Split( decoded.maps, "|" )

    local prefixes = {}
    for _, v in pairs( splitString ) do
        if v[1] == "^" then
            table.insert( prefixes, string.sub( v, 2 ) )
        else
            table.insert( prefixes, v )
        end
    end
    return prefixes
end

hook.Add( "PostGamemodeLoaded", "MapVote_GetMapPrefixesFromGamemode", function()
    MapVote.GamemodeMapPrefixes = MapVote.GetMapPrefixesFromGamemode()
end )

