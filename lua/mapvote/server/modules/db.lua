local DB = {}
MapVote.DB = DB
function DB.CreateTable()
	sql.Query( "CREATE TABLE IF NOT EXISTS mapvote_played_maps ( map TEXT UNIQUE, play_count INTEGER NOT NULL DEFAULT 0, last_played INTEGER )" )
end

function DB.MapPlayed( map )
    if sql.Query( string.format( "INSERT OR IGNORE INTO mapvote_played_maps (map) VALUES(%s)", sql.SQLStr( map ) ) ) == false then
    	print("MapVote SQLError: ", sql.LastError())
	end
    if sql.Query( string.format( "UPDATE mapvote_played_maps SET play_count = play_count +1, last_played=strftime('%%s') WHERE map = %s",  sql.SQLStr( map )  ) ) == false then
    	print("MapVote SQLError: ", sql.LastError())
	end
end

function DB.GetRecentMaps( limit )
    if not isnumber( limit ) then
        error( "DB.GetRecentMaps: Limit was not a number (" .. tostring( limit ) .. ")" )
    end

    local data = sql.Query( "SELECT * FROM mapvote_played_maps ORDER BY last_played DESC LIMIT " .. limit )
    if data == false then
        print("MapVote SQLError: ", sql.LastError())
    end
    return data
end

function DB.GetAllMaps()
    local data = sql.Query( "SELECT * FROM mapvote_played_maps" )
    if data == false then
        print("MapVote SQLError: ", sql.LastError())
    end

    return data
end

DB.CreateTable()
