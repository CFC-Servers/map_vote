
if GAMEMODE_NAME == "zombiesurvival" then
    hook.Add( "LoadNextMap", "MAPVOTEZS_LOADMAP", function()
        MapVote.Start()
        return true
    end )
end