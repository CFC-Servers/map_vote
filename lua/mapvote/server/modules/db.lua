local DB = {}
MapVote.DB = DB
function DB.CreateTable()
	sql.Query( "CREATE TABLE IF NOT EXISTS mapvote_played_maps ( map TEXT UNIQUE, play_count INTEGER, last_played INTEGER)" )
end

function DB.MapPlayed(map) 
    sql.Query( "INSERT OR IGNORE INTO mapvote_played_maps (map) VALUES(%S)", sql.SQLStr(map) )
    sql.Query( "UPDATE mapvote_played_maps SET play_count = play_count+1, last_played=unixepoch() WHERE map = %S",  sql.SQLStr(map) )
end

DB.CreateTable()
hook.Add("Initialize", "MapVote_UpdateDB", function()
    DB.MapPlayed(game.GetMap())
end)