local ThumbDownloader = MapVote.ThumbDownloader or {
    workshopIDLookup = {},
    mapsToDownload = {},
    ---@type table<string, fun( filepath: string )>
    mapDownloadCallbacks = {},
    urlOverrides = {},
    searchPaths = {
        "materials/mapvote/thumb_overrides/",
        "maps/thumb",
        "maps/thumb/",
        "maps/",
        "data/mapvote/thumb_cache/",
    },
    noIcon = "maps/thumb/noicon.png",
    thumbFilePathCache = {},
}


MapVote.ThumbDownloader = ThumbDownloader

-- TODO all net receivers should be in net.lua
net.Receive( "MapVote_WorkshopIDTable", function()
    ThumbDownloader.workshopIDLookup = net.ReadTable()
    print( string.format( "MapVote: Received %s workshop IDs", table.Count( ThumbDownloader.workshopIDLookup ) ) )
    ThumbDownloader:DownloadAll()
end )

function ThumbDownloader:getMapThumbnailFilePath( name )
    if self.thumbFilePathCache[name] then
        return self.thumbFilePathCache[name]
    end

    for _, path in ipairs( self.searchPaths ) do
        -- finding all the paths in bulk this way is faster than using file.Exists
        local thumbs = file.Find( path .. "*", "GAME" )
        for _, thumb in ipairs( thumbs ) do
            local extensionName = string.sub( thumb, -3, -1 )
            if extensionName == "png" or extensionName == "jpg" then
                local mapName = string.sub( thumb, 1, -5 )
                self.thumbFilePathCache[mapName] = path .. thumb
            end
        end
    end

    return self.thumbFilePathCache[name]
end

---@param map string
---@param callback fun( filepath: string )
function ThumbDownloader:QueueDownload( map, callback )
    local filePath = self:getMapThumbnailFilePath( map )
    if filePath then
        callback( filePath )
        return
    end

    print( "MapVote: Queued map thumb for download", map )
    self.mapDownloadCallbacks[map] = callback
    table.insert( self.mapsToDownload, map )
end

---@param map string
---@param url string
function ThumbDownloader:SetURLOverride( map, url )
    self.urlOverrides[map] = url
end

function ThumbDownloader:RequestWorkshopIDs()
    if #self.mapsToDownload == 0 then return end

    MapVote.Net.requestWorskhopIDs( self.mapsToDownload )
end

function ThumbDownloader:DownloadAll()
    print( "MapVote: Downloading all queued map thumbs" )
    local mapNamesByWorkshopID = {}
    local mapsToDownload = {}
    for _, map in pairs( self.mapsToDownload ) do
        local wsid = self.workshopIDLookup[map]
        if self.urlOverrides[map] then
            self:DownloadThumbnail( map, self.urlOverrides[map] )
        elseif wsid then
            mapNamesByWorkshopID[wsid] = mapNamesByWorkshopID[wsid] or {}
            table.insert( mapNamesByWorkshopID[wsid], map )
            table.insert( mapsToDownload, map )
        end
    end
    self.mapsToDownload = {}

    local requestBody = { ["itemcount"] = tostring( #mapsToDownload ) }
    for i, map in pairs( mapsToDownload ) do
        requestBody["publishedfileids[" .. tostring( i - 1 ) .. "]"] = self.workshopIDLookup[map]
    end

    http.Post( "https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/", requestBody,
        function( body, _, _, code )
            if code ~= 200 then
                print( "Non 200 response received from steam", code )
                return
            end
            local data = util.JSONToTable( body )
            if not data then return end
            if not data.response then return end
            if not data.response.publishedfiledetails then return end

            for _, addon in pairs( data.response.publishedfiledetails ) do
                if addon and addon.preview_url then
                    for _, map in pairs( mapNamesByWorkshopID[addon.publishedfileid] ) do
                        self:DownloadThumbnail( map, addon.preview_url )
                    end
                end
            end
        end
    )
end

function ThumbDownloader:DownloadThumbnail( name, url )
    file.CreateDir( "mapvote/thumb_cache" )
    local request = {
        failed = function( err )
            print( "MapVote: Failed to download map thumb", err )
            local callback = self.mapDownloadCallbacks[name]
            if callback then
                self.mapDownloadCallbacks[name] = nil
                callback( self.noIcon )
            end
        end,
        success = function( code, body, headers )
            if code < 200 or code > 299 then
                print( "MapVote: Failed to download map thumb, status code: ", code )
                return
            end
            local ext = ".png"
            if headers["Content-Type"] == "image/jpeg" then
                ext = ".jpg"
            end

            local filepath = "mapvote/thumb_cache/" .. name .. ext
            print( "MapVote: Downloaded map thumb", name, filepath )
            file.Write( filepath, body )

            local callback = self.mapDownloadCallbacks[name]
            if callback then
                self.mapDownloadCallbacks[name] = nil
                callback( "data/" .. filepath )
            end
        end,
        method = "GET",
        url = url,
        headers = {},
        timeout = 5,
    }
    HTTP( request )
end
