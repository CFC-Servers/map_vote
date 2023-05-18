MapVote.PermCanConfigure = "MapVoteConfigure"
hook.Add( "Initialize", "RegisterPerms", function()
    if not CAMI then return end
    CAMI.RegisterPrivilege {
        Name = MapVote.PermCanConfigure,
        MinAccess = "superadmin"
    }
end )
