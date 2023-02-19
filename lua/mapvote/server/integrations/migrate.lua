concommand.Add( "mapvote_migrate_playcounts", function( ply, cmd, args )
	if IsValid( ply ) and not ply:IsSuperAdmin() then return end
	local p = print
	if IsValid( ply ) then 
		p = function( msg ) ply:ChatPrint( msg ) end
	end

	local playCountsData = file.Read( "mapvote/playcounts.txt" or "{}" )
	if playCountsData == nil then 
		p( "could not find mapvote/playcounts.txt to migrate" )
		return 
	end
	local playCounts = util.JSONToTable( playCountsData )
	
	for map, count in pairs( playCounts ) do
		map = map:sub( 1, -5 )

		MapVote.DB.AddMap( map )
		MapVote.DB.AddPlayCount( map, count )
	end
	file.Rename( "mapvote/playcount.txt", "mapvote/playcount_backup.txt" )
	p( "MapVote migrated mapvote/playcounts.txt moving to mapvote/playcounts_backup.txt" )
end)
