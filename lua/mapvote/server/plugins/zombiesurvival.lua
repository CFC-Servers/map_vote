if engine.ActiveGamemode() == "zombiesurvival" then
    hook.Add( "LoadNextMap", "MAPVOTEZS_LOADMAP", function()
        MapVote.Start()
        return true
    end )
    return false
end

