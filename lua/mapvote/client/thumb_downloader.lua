MapVote.ThumbDownloader = MapVote.ThumbDownloader or {
    workshopIDLookup = {},
    mapsToDownload = {},
    mapDownloadCallbacks = {},
}

local ThumbDownloader = MapVote.ThumbDownloader

net.Receive( "MapVote_WorkshopIDTable", function()
    ThumbDownloader.workshopIDLookup = net.ReadTable()
end )

function ThumbDownloader:QueueDownload( map, callback )
    print( "MapVote: Queued map thumb for download", map )
    self.mapDownloadCallbacks[map] = callback
    table.insert( self.mapsToDownload, map )
end

function ThumbDownloader:DownloadAll()
    local mapNamesByWorkshopID = {}
    local mapsToDownload = {}
    for _, map in pairs( self.mapsToDownload ) do
        if self.workshopIDLookup[map] then
            mapNamesByWorkshopID[self.workshopIDLookup[map]] = map
            table.insert( mapsToDownload, map )
        end
    end
    self.mapsToDownload = {}

    local requestBody = { ["itemcount"] = tostring( #mapsToDownload ) }
    for i, map in pairs( mapsToDownload ) do
        print( "added " .. map .. "to request" )
        requestBody["publishedfileids[" .. tostring( i - 1 ) .. "]"] = self.workshopIDLookup[map]
    end

    http.Post( "https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/", requestBody,
        function( body )
            local data = util.JSONToTable( body )
            if not data then return end
            if not data.response then return end
            if not data.response.publishedfiledetails then return end

            for _, addon in pairs( data.response.publishedfiledetails ) do
                if addon and addon.preview_url then
                    self:DownloadThumbnail( mapNamesByWorkshopID[addon.publishedfileid], addon.preview_url )
                end
            end
        end
    )
end

function ThumbDownloader:DownloadThumbnail( name, url )
    http.Fetch( url, function( body, _, headers, _ )
        local ext = ".png"
        if headers["Content-Type"] == "image/jpeg" then
            ext = ".jpg"
        end
        print( "Downloaded map thumb", name )
        file.Write( "mapvote/thumb_cache" .. name .. ext, body )
        local callback = self.mapDownloadCallbacks[name]
        if callback then
            self.mapDownloadCallbacks[name] = nil
            callback( "data/mapvote/thumb_cache" .. name .. ext )
        end
    end )
end
