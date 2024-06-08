local DB = {}
MapVote.DB = DB
function DB.CreateTable()
    sql.Query(
        "CREATE TABLE IF NOT EXISTS mapvote_played_maps ( map TEXT UNIQUE, play_count INTEGER NOT NULL DEFAULT 0, last_played INTEGER )" )
end

---@param map string
function DB.MapPlayed( map )
    DB.AddMap( map )

    if sql.Query( string.format( "UPDATE mapvote_played_maps SET play_count = play_count +1, last_played=strftime('%%s') WHERE map = %s", sql.SQLStr( map ) ) ) == false then
        error( "MapVote SQLError: " .. sql.LastError() )
    end
end

---@param map string
function DB.AddMap( map )
    if sql.Query( string.format( "INSERT OR IGNORE INTO mapvote_played_maps (map) VALUES(%s)", sql.SQLStr( map ) ) ) == false then
        error( "MapVote SQLError: " .. sql.LastError() )
    end
end

---@param map string
---@param count number
function DB.AddPlayCount( map, count )
    if not isnumber( count ) then
        error( "DB.AddPlayCount: Count was not a number (" .. tostring( count ) .. ")" )
    end

    if sql.Query( string.format( "UPDATE mapvote_played_maps SET play_count = play_count + %s WHERE map = %s", count, sql.SQLStr( map ) ) ) == false then
        error( "MapVote SQLError: " .. sql.LastError() )
    end
end

---@param limit number
---@return {map:string, play_count:string, last_played:string}[]
function DB.GetRecentMaps( limit )
    if not isnumber( limit ) then
        error( "DB.GetRecentMaps: Limit was not a number (" .. tostring( limit ) .. ")" )
    end

    local data = sql.Query( "SELECT * FROM mapvote_played_maps ORDER BY last_played DESC LIMIT " .. limit )
    if data == false then
        error( "MapVote SQLError: " .. sql.LastError() )
    end
    return data
end

---@return {map:string, play_count:string, last_played:string}[]
function DB.GetAllMaps()
    local data = sql.Query( "SELECT * FROM mapvote_played_maps" )
    if data == false then
        error( "MapVote SQLError: " .. sql.LastError() )
    end

    return data
end

DB.CreateTable()
